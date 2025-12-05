import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/sensor_data.dart';
import '../../utils/app_colors.dart';
import '../../widgets/sensor_card.dart';
import '../../widgets/risk_indicator_card.dart';
import '../../widgets/vital_signs_card.dart';
import '../../widgets/ecg_waveform_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firebaseService = FirebaseService();
  final String _deviceId = 'ESP32_STROKE_001'; // Replace with actual device ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stroke Guardian',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Real-time Monitoring',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: StreamBuilder<SensorData?>(
              stream: _firebaseService.streamCurrentSensorData(_deviceId),
              builder: (context, snapshot) {
                final isConnected = snapshot.hasData;
                return Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isConnected ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConnected ? 'Connected' : 'Disconnected',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: isConnected ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<SensorData?>(
        stream: _firebaseService.streamCurrentSensorData(_deviceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Connecting to device...',
                    style: GoogleFonts.roboto(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data;

          if (data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sensors_off, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text(
                    'No sensor data available',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make sure your device is powered on and connected',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stroke Risk Indicator
                  RiskIndicatorCard(strokeRisk: data.strokeRisk),
                  const SizedBox(height: 16),

                  // Vital Signs Grid
                  VitalSignsCard(
                    heartRate: data.heartRate,
                    spo2: data.spo2,
                    temperature: data.temperature,
                  ),
                  const SizedBox(height: 16),

                  // ECG Waveform
                  ECGWaveformWidget(ecgData: data.ecg),
                  const SizedBox(height: 16),

                  // Detailed Sensor Cards
                  Text(
                    'Detailed Monitoring',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Heart Rate Card
                  SensorCard(
                    title: 'Heart Rate',
                    icon: Icons.favorite,
                    iconColor: AppColors.heartRate,
                    value: '${data.heartRate.avgBpm}',
                    unit: 'BPM',
                    subtitle: 'Average heart rate',
                    status: _getHeartRateStatus(data.heartRate.avgBpm),
                  ),
                  const SizedBox(height: 12),

                  // SpO2 Card
                  SensorCard(
                    title: 'Blood Oxygen (SpO2)',
                    icon: Icons.air,
                    iconColor: AppColors.spo2,
                    value: data.spo2.fingerDetected
                        ? '${data.spo2.value.toStringAsFixed(1)}'
                        : '--',
                    unit: '%',
                    subtitle: data.spo2.fingerDetected
                        ? 'Oxygen saturation'
                        : 'No finger detected',
                    status: data.spo2.status,
                  ),
                  const SizedBox(height: 12),

                  // HRV Card
                  SensorCard(
                    title: 'Heart Rate Variability',
                    icon: Icons.monitor_heart_outlined,
                    iconColor: AppColors.ecg,
                    value: data.ecg.leadsOff ? '--' : '${data.ecg.hrv.toStringAsFixed(0)}',
                    unit: 'ms',
                    subtitle: data.ecg.leadsOff
                        ? 'ECG leads disconnected'
                        : 'SDNN measurement',
                    status: _getHRVStatus(data.ecg.hrv, data.ecg.leadsOff),
                  ),
                  const SizedBox(height: 12),

                  // Motion Asymmetry Card
                  SensorCard(
                    title: 'Motion Asymmetry',
                    icon: Icons.accessibility_new,
                    iconColor: AppColors.motion,
                    value: '${data.motion.asymmetry.toStringAsFixed(1)}',
                    unit: 'm/s²',
                    subtitle: 'Body movement balance',
                    status: _getMotionStatus(data.motion.asymmetry),
                  ),
                  const SizedBox(height: 12),

                  // Temperature Card (if available)
                  if (data.temperature != null)
                    SensorCard(
                      title: 'Body Temperature',
                      icon: Icons.thermostat,
                      iconColor: AppColors.temperature,
                      value: '${data.temperature!.toStringAsFixed(1)}',
                      unit: '°C',
                      subtitle: 'Current temperature',
                      status: _getTemperatureStatus(data.temperature!),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getHeartRateStatus(int bpm) {
    if (bpm < 50) return 'Low';
    if (bpm > 100) return 'High';
    return 'Normal';
  }

  String _getHRVStatus(double hrv, bool leadsOff) {
    if (leadsOff) return 'No Signal';
    if (hrv > 100) return 'Irregular';
    if (hrv < 20) return 'Low Variability';
    return 'Normal';
  }

  String _getMotionStatus(double asymmetry) {
    if (asymmetry > 15) return 'High Asymmetry';
    if (asymmetry > 10) return 'Moderate';
    return 'Normal';
  }

  String _getTemperatureStatus(double temp) {
    if (temp < 36.0) return 'Low';
    if (temp > 37.5) return 'High';
    return 'Normal';
  }
}
