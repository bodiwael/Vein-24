import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sensor_data.dart';
import '../models/alert_model.dart';
import '../models/user_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;
  String? get userId => currentUser?.uid;

  // ========== Authentication ==========

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign up with email and password
  Future<User?> signUp(String email, String password, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);

        // Create user profile in Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'displayName': displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'devices': [],
          'emergencyContacts': [],
        });
      }

      return credential.user;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ========== User Profile ==========

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(uid, doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // ========== Real-time Sensor Data ==========

  // Stream current sensor data
  Stream<SensorData?> streamCurrentSensorData(String deviceId) {
    if (userId == null) return Stream.value(null);

    return _realtimeDb
        .ref('users/$userId/devices/$deviceId/currentData')
        .onValue
        .map((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return SensorData.fromJson(data);
      }
      return null;
    });
  }

  // Get historical sensor data
  Future<List<SensorData>> getHistoricalData(
    String deviceId, {
    int limit = 100,
  }) async {
    if (userId == null) return [];

    try {
      final snapshot = await _realtimeDb
          .ref('users/$userId/devices/$deviceId/history')
          .orderByKey()
          .limitToLast(limit)
          .get();

      if (snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.entries
            .map((e) => SensorData.fromJson(Map<String, dynamic>.from(e.value)))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get historical data: $e');
    }
  }

  // ========== Alerts ==========

  // Stream alerts
  Stream<List<AlertModel>> streamAlerts() {
    if (userId == null) return Stream.value([]);

    return _realtimeDb
        .ref('users/$userId/alerts')
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return data.entries
            .map((e) => AlertModel.fromJson(
                  e.key,
                  Map<String, dynamic>.from(e.value),
                ))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      return <AlertModel>[];
    });
  }

  // Mark alert as read
  Future<void> markAlertAsRead(String alertId) async {
    if (userId == null) return;

    try {
      await _realtimeDb.ref('users/$userId/alerts/$alertId').update({
        'read': true,
      });
    } catch (e) {
      throw Exception('Failed to mark alert as read: $e');
    }
  }

  // Delete alert
  Future<void> deleteAlert(String alertId) async {
    if (userId == null) return;

    try {
      await _realtimeDb.ref('users/$userId/alerts/$alertId').remove();
    } catch (e) {
      throw Exception('Failed to delete alert: $e');
    }
  }

  // Clear all alerts
  Future<void> clearAllAlerts() async {
    if (userId == null) return;

    try {
      await _realtimeDb.ref('users/$userId/alerts').remove();
    } catch (e) {
      throw Exception('Failed to clear alerts: $e');
    }
  }

  // ========== Devices ==========

  // Add device to user
  Future<void> addDevice(String deviceId) async {
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'devices': FieldValue.arrayUnion([deviceId]),
      });
    } catch (e) {
      throw Exception('Failed to add device: $e');
    }
  }

  // Remove device from user
  Future<void> removeDevice(String deviceId) async {
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'devices': FieldValue.arrayRemove([deviceId]),
      });
    } catch (e) {
      throw Exception('Failed to remove device: $e');
    }
  }

  // ========== Emergency Contacts ==========

  // Add emergency contact
  Future<void> addEmergencyContact(String phoneNumber) async {
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'emergencyContacts': FieldValue.arrayUnion([phoneNumber]),
      });
    } catch (e) {
      throw Exception('Failed to add emergency contact: $e');
    }
  }

  // Remove emergency contact
  Future<void> removeEmergencyContact(String phoneNumber) async {
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'emergencyContacts': FieldValue.arrayRemove([phoneNumber]),
      });
    } catch (e) {
      throw Exception('Failed to remove emergency contact: $e');
    }
  }

  // ========== Helper Methods ==========

  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'invalid-email':
          return 'Email address is invalid.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        default:
          return e.message ?? 'Authentication failed.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
