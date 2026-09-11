import 'package:intl/intl.dart';

class AttendanceModel {
  final String id;
  final String userId;
  final String employeeId;
  final String date; // YYYY-MM-DD
  final String checkInTime; // e.g., 08:03 AM
  final String status; // Present / Late
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime createdAt;
  final bool isGeoVerified;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.date,
    required this.checkInTime,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.createdAt,
    this.isGeoVerified = true,
  });

  String get formattedDisplayDate {
    try {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) {
        return DateFormat('MMMM d, yyyy').format(parsed);
      }
    } catch (_) {}
    return date;
  }

  String get formattedDisplayDayDate {
    try {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) {
        return DateFormat('EEEE, d MMMM yyyy').format(parsed);
      }
    } catch (_) {}
    return date;
  }

  String get coordinatesShort =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'employeeId': employeeId,
      'date': date,
      'checkInTime': checkInTime,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'createdAt': createdAt.toIso8601String(),
      'isGeoVerified': isGeoVerified,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parseDateTime(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      try {
        return (val as dynamic).toDate();
      } catch (_) {
        return DateTime.now();
      }
    }

    return AttendanceModel(
      id: id ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      employeeId: map['employeeId'] ?? '',
      date: map['date'] ?? '',
      checkInTime: map['checkInTime'] ?? '',
      status: map['status'] ?? 'Present',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      locationName: map['locationName'] ?? 'Office Location',
      createdAt: parseDateTime(map['createdAt']),
      isGeoVerified: map['isGeoVerified'] ?? true,
    );
  }
}
