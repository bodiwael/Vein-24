class SensorData {
  final DateTime timestamp;
  final HeartRateData heartRate;
  final SpO2Data spo2;
  final MotionData motion;
  final ECGData ecg;
  final StrokeRiskData strokeRisk;
  final double? temperature;

  SensorData({
    required this.timestamp,
    required this.heartRate,
    required this.spo2,
    required this.motion,
    required this.ecg,
    required this.strokeRisk,
    this.temperature,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      heartRate: HeartRateData.fromJson(json['heartRate'] ?? {}),
      spo2: SpO2Data.fromJson(json['spo2'] ?? {}),
      motion: MotionData.fromJson(json['motion'] ?? {}),
      ecg: ECGData.fromJson(json['ecg'] ?? {}),
      strokeRisk: StrokeRiskData.fromJson(json['strokeRisk'] ?? {}),
      temperature: (json['temperature'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'heartRate': heartRate.toJson(),
      'spo2': spo2.toJson(),
      'motion': motion.toJson(),
      'ecg': ecg.toJson(),
      'strokeRisk': strokeRisk.toJson(),
      'temperature': temperature,
    };
  }
}

class HeartRateData {
  final double bpm;
  final int avgBpm;
  final int irValue;

  HeartRateData({
    required this.bpm,
    required this.avgBpm,
    required this.irValue,
  });

  factory HeartRateData.fromJson(Map<String, dynamic> json) {
    return HeartRateData(
      bpm: (json['bpm'] as num?)?.toDouble() ?? 0.0,
      avgBpm: (json['avgBpm'] as num?)?.toInt() ?? 0,
      irValue: (json['irValue'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bpm': bpm,
      'avgBpm': avgBpm,
      'irValue': irValue,
    };
  }
}

class SpO2Data {
  final double value;
  final bool fingerDetected;

  SpO2Data({
    required this.value,
    required this.fingerDetected,
  });

  factory SpO2Data.fromJson(Map<String, dynamic> json) {
    return SpO2Data(
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      fingerDetected: json['fingerDetected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'fingerDetected': fingerDetected,
    };
  }

  String get status {
    if (!fingerDetected) return 'No Signal';
    if (value >= 95) return 'Normal';
    if (value >= 90) return 'Low';
    return 'Critical';
  }
}

class MotionData {
  final double accelX;
  final double accelY;
  final double accelZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final double asymmetry;

  MotionData({
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.asymmetry,
  });

  factory MotionData.fromJson(Map<String, dynamic> json) {
    return MotionData(
      accelX: (json['accelX'] as num?)?.toDouble() ?? 0.0,
      accelY: (json['accelY'] as num?)?.toDouble() ?? 0.0,
      accelZ: (json['accelZ'] as num?)?.toDouble() ?? 0.0,
      gyroX: (json['gyroX'] as num?)?.toDouble() ?? 0.0,
      gyroY: (json['gyroY'] as num?)?.toDouble() ?? 0.0,
      gyroZ: (json['gyroZ'] as num?)?.toDouble() ?? 0.0,
      asymmetry: (json['asymmetry'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accelX': accelX,
      'accelY': accelY,
      'accelZ': accelZ,
      'gyroX': gyroX,
      'gyroY': gyroY,
      'gyroZ': gyroZ,
      'asymmetry': asymmetry,
    };
  }
}

class ECGData {
  final int value;
  final bool leadsOff;
  final double hrv;

  ECGData({
    required this.value,
    required this.leadsOff,
    required this.hrv,
  });

  factory ECGData.fromJson(Map<String, dynamic> json) {
    return ECGData(
      value: (json['value'] as num?)?.toInt() ?? 0,
      leadsOff: json['leadsOff'] ?? true,
      hrv: (json['hrv'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'leadsOff': leadsOff,
      'hrv': hrv,
    };
  }
}

class StrokeRiskData {
  final int level;
  final bool atrialFib;
  final bool lowSpO2;
  final bool motionAsymmetry;

  StrokeRiskData({
    required this.level,
    required this.atrialFib,
    required this.lowSpO2,
    required this.motionAsymmetry,
  });

  factory StrokeRiskData.fromJson(Map<String, dynamic> json) {
    return StrokeRiskData(
      level: (json['level'] as num?)?.toInt() ?? 0,
      atrialFib: json['atrialFib'] ?? false,
      lowSpO2: json['lowSpO2'] ?? false,
      motionAsymmetry: json['motionAsymmetry'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'atrialFib': atrialFib,
      'lowSpO2': lowSpO2,
      'motionAsymmetry': motionAsymmetry,
    };
  }

  String get riskLevelText {
    switch (level) {
      case 0:
        return 'Normal';
      case 1:
        return 'Low Risk';
      case 2:
        return 'Medium Risk';
      case 3:
        return 'High Risk';
      default:
        return 'Unknown';
    }
  }

  String get riskDescription {
    if (level == 0) return 'All parameters within normal range';

    List<String> indicators = [];
    if (atrialFib) indicators.add('Irregular heart rhythm');
    if (lowSpO2) indicators.add('Low oxygen saturation');
    if (motionAsymmetry) indicators.add('Movement asymmetry');

    return indicators.join(', ');
  }
}
