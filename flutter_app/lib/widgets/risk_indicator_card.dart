import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sensor_data.dart';
import '../utils/app_colors.dart';

class RiskIndicatorCard extends StatelessWidget {
  final StrokeRiskData strokeRisk;

  const RiskIndicatorCard({
    Key? key,
    required this.strokeRisk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor(strokeRisk.level);
    final riskIcon = _getRiskIcon(strokeRisk.level);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            riskColor,
            riskColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: riskColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    riskIcon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // Title and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stroke Risk Level',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strokeRisk.riskLevelText,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Risk Level Number
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${strokeRisk.level}',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Risk Description
            if (strokeRisk.level > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        strokeRisk.riskDescription,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Risk Indicators
            if (strokeRisk.atrialFib ||
                strokeRisk.lowSpO2 ||
                strokeRisk.motionAsymmetry) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (strokeRisk.atrialFib)
                    _buildRiskBadge('Irregular Rhythm'),
                  if (strokeRisk.atrialFib && strokeRisk.lowSpO2)
                    const SizedBox(width: 8),
                  if (strokeRisk.lowSpO2) _buildRiskBadge('Low SpO2'),
                  if ((strokeRisk.atrialFib || strokeRisk.lowSpO2) &&
                      strokeRisk.motionAsymmetry)
                    const SizedBox(width: 8),
                  if (strokeRisk.motionAsymmetry)
                    _buildRiskBadge('Asymmetry'),
                ],
              ),
            ],

            // Action Button for High Risk
            if (strokeRisk.level >= 3) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Call emergency or show emergency dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: riskColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Call Emergency',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
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

  IconData _getRiskIcon(int level) {
    switch (level) {
      case 0:
        return Icons.check_circle;
      case 1:
        return Icons.warning_amber;
      case 2:
        return Icons.error_outline;
      case 3:
        return Icons.emergency;
      default:
        return Icons.help_outline;
    }
  }
}
