import 'package:cloud_firestore/cloud_firestore.dart';

enum RideStatus { safe, alert, incident }

class RideModel {
  final String id;
  final String title;
  final RideStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final double distanceKm;
  final double avgSpeedKmh;
  final String? location;
  final String? alertNote;

  RideModel({
    required this.id,
    required this.title,
    required this.status,
    required this.startTime,
    this.endTime,
    this.distanceKm = 0,
    this.avgSpeedKmh = 0,
    this.location,
    this.alertNote,
  });

  /// Duration in minutes
  int get durationMinutes {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMinutes;
  }

  String get durationLabel {
    final mins = durationMinutes;
    if (mins < 60) return '${mins}m';
    return '${mins ~/ 60}h ${mins % 60}m';
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'status': status.name,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'distanceKm': distanceKm,
      'avgSpeedKmh': avgSpeedKmh,
      'location': location,
      'alertNote': alertNote,
    };
  }

  factory RideModel.fromFirestore(String id, Map<String, dynamic> data) {
    return RideModel(
      id: id,
      title: data['title'] ?? 'Ride',
      status: RideStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => RideStatus.safe,
      ),
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0,
      avgSpeedKmh: (data['avgSpeedKmh'] as num?)?.toDouble() ?? 0,
      location: data['location'],
      alertNote: data['alertNote'],
    );
  }
}
