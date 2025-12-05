import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sensor_data.dart';
import '../utils/app_colors.dart';
import 'dart:math' as math;

class ECGWaveformWidget extends StatefulWidget {
  final ECGData ecgData;

  const ECGWaveformWidget({
    Key? key,
    required this.ecgData,
  }) : super(key: key);

  @override
  State<ECGWaveformWidget> createState() => _ECGWaveformWidgetState();
}

class _ECGWaveformWidgetState extends State<ECGWaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<double> _ecgValues = [];
  final int _maxDataPoints = 100;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..repeat();

    _animationController.addListener(() {
      if (mounted) {
        setState(() {
          // Add new ECG value
          _ecgValues.add(widget.ecgData.value.toDouble());

          // Keep only the last N data points
          if (_ecgValues.length > _maxDataPoints) {
            _ecgValues.removeAt(0);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ECG Monitor',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.ecgData.leadsOff
                          ? 'Leads disconnected'
                          : 'Real-time ECG signal',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: widget.ecgData.leadsOff
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.ecgData.leadsOff
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.ecg.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.ecgData.leadsOff
                              ? AppColors.error
                              : AppColors.ecg,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.ecgData.leadsOff ? 'Offline' : 'Live',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: widget.ecgData.leadsOff
                              ? AppColors.error
                              : AppColors.ecg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ECG Waveform Display
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.ecgData.leadsOff
                    ? Center(
                        child: Text(
                          'No Signal',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : CustomPaint(
                        painter: ECGPainter(
                          dataPoints: _ecgValues,
                          color: AppColors.ecg,
                        ),
                        child: Container(),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // HRV Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  label: 'HRV',
                  value: widget.ecgData.leadsOff
                      ? '--'
                      : '${widget.ecgData.hrv.toStringAsFixed(0)} ms',
                ),
                _buildInfoItem(
                  label: 'ECG Value',
                  value: widget.ecgData.leadsOff
                      ? '--'
                      : widget.ecgData.value.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class ECGPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color color;

  ECGPainter({
    required this.dataPoints,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    // Vertical grid lines
    for (int i = 0; i < 10; i++) {
      final x = (size.width / 10) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Horizontal grid lines
    for (int i = 0; i < 5; i++) {
      final y = (size.height / 5) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Normalize data
    final maxValue = dataPoints.reduce(math.max);
    final minValue = dataPoints.reduce(math.min);
    final range = maxValue - minValue;

    if (range == 0) return;

    // Draw ECG waveform
    final path = Path();
    for (int i = 0; i < dataPoints.length; i++) {
      final x = (size.width / dataPoints.length) * i;
      final normalizedValue = (dataPoints[i] - minValue) / range;
      final y = size.height - (normalizedValue * size.height * 0.8) -
          (size.height * 0.1);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ECGPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints;
  }
}
