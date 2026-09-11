import 'package:intl/intl.dart';

class AttendanceModel {
  final String id;
  final String userId;
  final String employeeId;
  final String date; // YYYY-MM-DD
  final String checkInTime; // e.g., 08:03 AM
  final String? checkOutTime; // e.g., 17:05 PM
  final String status; // Present / Late
  final double latitude;
  final double longitude;
  final String locationName;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? checkOutLocationName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isGeoVerified;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkOutLocationName,
    required this.createdAt,
    this.updatedAt,
    this.isGeoVerified = true,
  });

  bool get hasCheckedOut => checkOutTime != null && checkOutTime!.isNotEmpty;

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

  String get checkOutCoordinatesShort =>
      (checkOutLatitude != null && checkOutLongitude != null)
          ? '${checkOutLatitude!.toStringAsFixed(5)}, ${checkOutLongitude!.toStringAsFixed(5)}'
          : '';

  AttendanceModel copyWith({
    String? id,
    String? userId,
    String? employeeId,
    String? date,
    String? checkInTime,
    String? checkOutTime,
    String? status,
    double? latitude,
    double? longitude,
    String? locationName,
    double? checkOutLatitude,
    double? checkOutLongitude,
    String? checkOutLocationName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isGeoVerified,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      checkOutLatitude: checkOutLatitude ?? this.checkOutLatitude,
      checkOutLongitude: checkOutLongitude ?? this.checkOutLongitude,
      checkOutLocationName: checkOutLocationName ?? this.checkOutLocationName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isGeoVerified: isGeoVerified ?? this.isGeoVerified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'employeeId': employeeId,
      'date': date,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'checkOutLatitude': checkOutLatitude,
      'checkOutLongitude': checkOutLongitude,
      'checkOutLocationName': checkOutLocationName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
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

    DateTime? parseOptionalDateTime(dynamic val) {
      if (val == null) return null;
      if (val is String) return DateTime.tryParse(val);
      try {
        return (val as dynamic).toDate();
      } catch (_) {
        return null;
      }
    }

    return AttendanceModel(
      id: id ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      employeeId: map['employeeId'] ?? '',
      date: map['date'] ?? '',
      checkInTime: map['checkInTime'] ?? '',
      checkOutTime: map['checkOutTime'],
      status: map['status'] ?? 'Present',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      locationName: map['locationName'] ?? 'Office Location',
      checkOutLatitude: (map['checkOutLatitude'] as num?)?.toDouble(),
      checkOutLongitude: (map['checkOutLongitude'] as num?)?.toDouble(),
      checkOutLocationName: map['checkOutLocationName'],
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseOptionalDateTime(map['updatedAt']),
      isGeoVerified: map['isGeoVerified'] ?? true,
    );
  }
}
