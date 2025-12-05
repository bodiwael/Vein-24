import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sensor_data.dart';
import '../utils/app_colors.dart';

class VitalSignsCard extends StatelessWidget {
  final HeartRateData heartRate;
  final SpO2Data spo2;
  final double? temperature;

  const VitalSignsCard({
    Key? key,
    required this.heartRate,
    required this.spo2,
    this.temperature,
  }) : super(key: key);

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
            Text(
              'Vital Signs',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Heart Rate
                Expanded(
                  child: _buildVitalItem(
                    icon: Icons.favorite,
                    iconColor: AppColors.heartRate,
                    label: 'Heart Rate',
                    value: '${heartRate.avgBpm}',
                    unit: 'BPM',
                  ),
                ),

                Container(
                  width: 1,
                  height: 60,
                  color: AppColors.border,
                ),

                // SpO2
                Expanded(
                  child: _buildVitalItem(
                    icon: Icons.air,
                    iconColor: AppColors.spo2,
                    label: 'SpO2',
                    value: spo2.fingerDetected
                        ? spo2.value.toStringAsFixed(0)
                        : '--',
                    unit: '%',
                  ),
                ),

                if (temperature != null) ...[
                  Container(
                    width: 1,
                    height: 60,
                    color: AppColors.border,
                  ),

                  // Temperature
                  Expanded(
                    child: _buildVitalItem(
                      icon: Icons.thermostat,
                      iconColor: AppColors.temperature,
                      label: 'Temp',
                      value: temperature!.toStringAsFixed(1),
                      unit: '°C',
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                unit,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
