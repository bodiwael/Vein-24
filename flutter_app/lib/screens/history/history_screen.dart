import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../models/sensor_data.dart';
import '../../utils/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _firebaseService = FirebaseService();
  final String _deviceId = 'ESP32_STROKE_001';

  String _selectedMetric = 'Heart Rate';
  List<SensorData> _historicalData = [];
  bool _isLoading = true;

  final List<String> _metrics = [
    'Heart Rate',
    'SpO2',
    'HRV',
    'Motion Asymmetry',
    'Stroke Risk',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistoricalData();
  }

  Future<void> _loadHistoricalData() async {
    setState(() => _isLoading = true);

    try {
      final data = await _firebaseService.getHistoricalData(
        _deviceId,
        limit: 50,
      );
      setState(() {
        _historicalData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Health History',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadHistoricalData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _historicalData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No historical data available',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metric Selector
                      _buildMetricSelector(),
                      const SizedBox(height: 20),

                      // Chart
                      _buildChart(),
                      const SizedBox(height: 20),

                      // Statistics Summary
                      _buildStatistics(),
                      const SizedBox(height: 20),

                      // Recent Readings List
                      _buildRecentReadings(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMetricSelector() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _metrics.length,
        itemBuilder: (context, index) {
          final metric = _metrics[index];
          final isSelected = metric == _selectedMetric;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(metric),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedMetric = metric);
                }
              },
              backgroundColor: AppColors.cardBackground,
              selectedColor: AppColors.primary,
              labelStyle: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          _getChartData(),
        ),
      ),
    );
  }

  LineChartData _getChartData() {
    final spots = _getDataPoints();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: spots.length > 10 ? (spots.length / 5).ceilToDouble() : 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= _historicalData.length) return Text('');
              final data = _historicalData[value.toInt()];
              return Text(
                DateFormat('HH:mm').format(data.timestamp),
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: _getMetricColor(),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: _getMetricColor().withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getDataPoints() {
    final List<FlSpot> spots = [];

    for (int i = 0; i < _historicalData.length; i++) {
      final data = _historicalData[i];
      double value = 0;

      switch (_selectedMetric) {
        case 'Heart Rate':
          value = data.heartRate.avgBpm.toDouble();
          break;
        case 'SpO2':
          value = data.spo2.value;
          break;
        case 'HRV':
          value = data.ecg.hrv;
          break;
        case 'Motion Asymmetry':
          value = data.motion.asymmetry;
          break;
        case 'Stroke Risk':
          value = data.strokeRisk.level.toDouble();
          break;
      }

      spots.add(FlSpot(i.toDouble(), value));
    }

    return spots;
  }

  Color _getMetricColor() {
    switch (_selectedMetric) {
      case 'Heart Rate':
        return AppColors.heartRate;
      case 'SpO2':
        return AppColors.spo2;
      case 'HRV':
        return AppColors.ecg;
      case 'Motion Asymmetry':
        return AppColors.motion;
      case 'Stroke Risk':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildStatistics() {
    final values = _getDataPoints().map((spot) => spot.y).toList();
    if (values.isEmpty) return const SizedBox();

    final avg = values.reduce((a, b) => a + b) / values.length;
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Average', avg.toStringAsFixed(1)),
                _buildStatItem('Maximum', max.toStringAsFixed(1)),
                _buildStatItem('Minimum', min.toStringAsFixed(1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReadings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Readings',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _historicalData.take(10).length,
          itemBuilder: (context, index) {
            final data = _historicalData[index];
            return _buildReadingItem(data);
          },
        ),
      ],
    );
  }

  Widget _buildReadingItem(SensorData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.lightShadow],
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getRiskColor(data.strokeRisk.level).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.favorite,
            color: _getRiskColor(data.strokeRisk.level),
          ),
        ),
        title: Text(
          DateFormat('MMM d, yyyy - HH:mm').format(data.timestamp),
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'HR: ${data.heartRate.avgBpm} BPM | SpO2: ${data.spo2.value.toStringAsFixed(0)}% | Risk: ${data.strokeRisk.riskLevelText}',
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Color _getRiskColor(int level) {
    switch (level) {
      case 0:
        return AppColors.riskNormal;
      case 1:
        return AppColors.riskLow;
      case 2:
        return AppColors.riskMedium;
      case 3:
        return AppColors.riskHigh;
      default:
        return AppColors.riskNormal;
    }
  }
}
