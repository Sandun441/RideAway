import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/ride_model.dart';

class RideService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _ridesRef {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return _db.collection('users').doc(user.uid).collection('rides');
  }

  /// Save a completed ride to Firestore
  Future<void> saveRide(RideModel ride) async {
    try {
      if (ride.id.isEmpty) {
        await _ridesRef.add(ride.toMap());
      } else {
        await _ridesRef.doc(ride.id).set(ride.toMap());
      }
      debugPrint('Ride saved successfully.');
    } catch (e) {
      debugPrint('Error saving ride: $e');
      rethrow;
    }
  }

  /// Stream of all rides, newest first
  Stream<List<RideModel>> getRides() {
    return _ridesRef
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => RideModel.fromFirestore(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ))
            .toList());
  }

  /// Stream filtered by status
  Stream<List<RideModel>> getRidesByStatus(RideStatus status) {
    return _ridesRef
        .where('status', isEqualTo: status.name)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => RideModel.fromFirestore(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ))
            .toList());
  }

  /// Get monthly summary stats
  Future<Map<String, dynamic>> getMonthlySummary() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final snap = await _ridesRef
          .where('startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      final rides = snap.docs
          .map((doc) => RideModel.fromFirestore(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ))
          .toList();

      final totalRides = rides.length;
      final totalKm = rides.fold<double>(0, (sum, r) => sum + r.distanceKm);
      final incidents =
          rides.where((r) => r.status == RideStatus.incident).length;

      return {
        'totalRides': totalRides,
        'totalKm': totalKm.toStringAsFixed(1),
        'incidents': incidents,
      };
    } catch (e) {
      debugPrint('Error getting monthly summary: $e');
      return {'totalRides': 0, 'totalKm': '0.0', 'incidents': 0};
    }
  }
}
