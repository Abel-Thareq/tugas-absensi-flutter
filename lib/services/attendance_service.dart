import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  FirebaseFirestore? _firestore;
  bool _isFirebaseAvailable = false;

  // In-memory cache of records for local fallback
  final List<AttendanceModel> _localRecords = [];

  void configureFirebase({required bool available}) {
    _isFirebaseAvailable = available;
    if (available) {
      try {
        _firestore = FirebaseFirestore.instance;
      } catch (e) {
        _isFirebaseAvailable = false;
        debugPrint('Firestore not available: $e');
      }
    }
  }

  String getTodayDateString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  /// Check if user has already checked in today
  Future<AttendanceModel?> getTodayAttendance(String userId) async {
    final todayStr = getTodayDateString();

    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final querySnapshot = await _firestore!
            .collection(AppConstants.attendanceCollection)
            .where('userId', isEqualTo: userId)
            .where('date', isEqualTo: todayStr)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          return AttendanceModel.fromMap(doc.data(), id: doc.id);
        }
        return null;
      } catch (e) {
        debugPrint('Firestore getTodayAttendance error: $e');
        // Fall back to local check if network/read error
      }
    }

    // Local check
    await _loadLocalRecordsIfEmpty(userId);
    try {
      return _localRecords.firstWhere(
        (r) => r.userId == userId && r.date == todayStr,
      );
    } catch (_) {
      return null;
    }
  }

  /// Submit new attendance check-in
  Future<AttendanceModel> submitCheckIn({
    required UserModel user,
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    final now = DateTime.now();
    final todayStr = getTodayDateString();
    final timeStr = DateFormat('hh:mm a').format(now);

    // 1. Strict duplicate validation before write
    final existing = await getTodayAttendance(user.id);
    if (existing != null) {
      throw Exception('Anda sudah melakukan presensi hari ini pada pukul ${existing.checkInTime}. Presensi hanya dapat dilakukan 1 kali per hari.');
    }

    final newAttendance = AttendanceModel(
      id: 'att_${user.id}_${todayStr.replaceAll('-', '')}',
      userId: user.id,
      employeeId: user.employeeId,
      date: todayStr,
      checkInTime: timeStr,
      status: 'Present',
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      createdAt: now,
      isGeoVerified: true,
    );

    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final data = newAttendance.toMap();
        // Use server timestamp for tamper-proof recording
        data['createdAt'] = FieldValue.serverTimestamp();

        await _firestore!
            .collection(AppConstants.attendanceCollection)
            .doc(newAttendance.id)
            .set(data);

        // Also add to local cache for instant UI response
        _localRecords.removeWhere((r) => r.id == newAttendance.id);
        _localRecords.insert(0, newAttendance);
        await _saveLocalRecords(user.id);

        return newAttendance;
      } catch (e) {
        debugPrint('Firestore write error: $e');
        throw Exception('Gagal menyimpan presensi ke Firebase Cloud Firestore: ${e.toString()}');
      }
    } else {
      // Local fallback recording
      await Future.delayed(const Duration(milliseconds: 600));
      _localRecords.removeWhere((r) => r.id == newAttendance.id);
      _localRecords.insert(0, newAttendance);
      await _saveLocalRecords(user.id);
      return newAttendance;
    }
  }

  /// Get chronological attendance history for user
  Future<List<AttendanceModel>> getAttendanceHistory(String userId) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot;
        try {
          querySnapshot = await _firestore!
              .collection(AppConstants.attendanceCollection)
              .where('userId', isEqualTo: userId)
              .orderBy('date', descending: true)
              .get();
        } catch (indexError) {
          debugPrint('Composite index note, falling back to client sort: $indexError');
          querySnapshot = await _firestore!
              .collection(AppConstants.attendanceCollection)
              .where('userId', isEqualTo: userId)
              .get();
        }

        if (querySnapshot.docs.isNotEmpty) {
          final list = querySnapshot.docs
              .map((doc) => AttendanceModel.fromMap(doc.data(), id: doc.id))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        }
      } catch (e) {
        debugPrint('Firestore getAttendanceHistory error: $e');
      }
    }

    // Local fallback history
    await _loadLocalRecordsIfEmpty(userId);
    final userRecords = _localRecords.where((r) => r.userId == userId).toList();
    userRecords.sort((a, b) => b.date.compareTo(a.date));
    return userRecords;
  }

  /// Seed initial realistic records if first launch
  Future<void> _loadLocalRecordsIfEmpty(String userId) async {
    if (_localRecords.isNotEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getString('saved_attendance_$userId');
    if (savedJson != null && savedJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(savedJson);
        _localRecords.clear();
        _localRecords.addAll(list.map((m) => AttendanceModel.fromMap(m)));
        return;
      } catch (e) {
        debugPrint('Failed to parse saved attendance: $e');
      }
    }

    // Seed historical records (matching the design specifications)
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    final threeDaysAgo = now.subtract(const Duration(days: 3));

    _localRecords.addAll([
      AttendanceModel(
        id: 'hist_1',
        userId: userId,
        employeeId: AppConstants.demoEmployeeId,
        date: DateFormat('yyyy-MM-dd').format(yesterday),
        checkInTime: '08:07 AM',
        status: 'Present',
        latitude: AppConstants.defaultOfficeLatitude,
        longitude: AppConstants.defaultOfficeLongitude,
        locationName: 'Kantor Pusat • Terverifikasi',
        createdAt: yesterday,
      ),
      AttendanceModel(
        id: 'hist_2',
        userId: userId,
        employeeId: AppConstants.demoEmployeeId,
        date: DateFormat('yyyy-MM-dd').format(twoDaysAgo),
        checkInTime: '08:01 AM',
        status: 'Present',
        latitude: AppConstants.defaultOfficeLatitude,
        longitude: AppConstants.defaultOfficeLongitude,
        locationName: 'Kantor Pusat • Terverifikasi',
        createdAt: twoDaysAgo,
      ),
      AttendanceModel(
        id: 'hist_3',
        userId: userId,
        employeeId: AppConstants.demoEmployeeId,
        date: DateFormat('yyyy-MM-dd').format(threeDaysAgo),
        checkInTime: '08:05 AM',
        status: 'Present',
        latitude: AppConstants.defaultOfficeLatitude,
        longitude: AppConstants.defaultOfficeLongitude,
        locationName: 'Kantor Pusat • Terverifikasi',
        createdAt: threeDaysAgo,
      ),
    ]);
  }

  Future<void> _saveLocalRecords(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = _localRecords.where((r) => r.userId == userId).map((r) => r.toMap()).toList();
    await prefs.setString('saved_attendance_$userId', jsonEncode(list));
  }
}
