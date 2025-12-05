class AlertModel {
  final String id;
  final String type;
  final String message;
  final DateTime timestamp;
  final String deviceId;
  final bool read;

  AlertModel({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.deviceId,
    required this.read,
  });

  factory AlertModel.fromJson(String id, Map<String, dynamic> json) {
    return AlertModel(
      id: id,
      type: json['type'] ?? 'UNKNOWN',
      message: json['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      deviceId: json['deviceId'] ?? '',
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'deviceId': deviceId,
      'read': read,
    };
  }

  AlertModel copyWith({
    String? id,
    String? type,
    String? message,
    DateTime? timestamp,
    String? deviceId,
    bool? read,
  }) {
    return AlertModel(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      deviceId: deviceId ?? this.deviceId,
      read: read ?? this.read,
    );
  }

  String get severityLevel {
    switch (type) {
      case 'HIGH_RISK':
      case 'CRITICAL':
        return 'Critical';
      case 'MEDIUM_RISK':
        return 'Warning';
      case 'LOW_RISK':
        return 'Caution';
      default:
        return 'Info';
    }
  }

  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
