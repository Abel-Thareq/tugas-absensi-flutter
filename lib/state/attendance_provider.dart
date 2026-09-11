import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';
import '../services/attendance_service.dart';
import '../services/location_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final LocationService _locationService = LocationService();

  AttendanceModel? _todayAttendance;
  List<AttendanceModel> _historyList = [];

  bool _isLoadingToday = false;
  bool _isLoadingHistory = false;
  bool _isGettingLocation = false;
  bool _isSubmittingCheckIn = false;
  bool _isSubmittingCheckOut = false;

  LocationResult? _currentLocationResult;
  String? _errorMessage;

  AttendanceModel? get todayAttendance => _todayAttendance;
  bool get hasCheckedInToday => _todayAttendance != null;
  bool get hasCheckedOutToday => _todayAttendance?.hasCheckedOut ?? false;
  bool get isTodayFullyCompleted => hasCheckedInToday && hasCheckedOutToday;
  List<AttendanceModel> get historyList => _historyList;

  bool get isLoadingToday => _isLoadingToday;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isGettingLocation => _isGettingLocation;
  bool get isSubmittingCheckIn => _isSubmittingCheckIn;
  bool get isSubmittingCheckOut => _isSubmittingCheckOut;
  bool get isProcessing => _isGettingLocation || _isSubmittingCheckIn || _isSubmittingCheckOut;

  LocationResult? get currentLocationResult => _currentLocationResult;
  String? get errorMessage => _errorMessage;

  String getTodayDateString() => _attendanceService.getTodayDateString();

  /// Loads today's attendance status and recent records for the dashboard
  Future<void> loadDashboardData(String userId) async {
    _isLoadingToday = true;
    _isLoadingHistory = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _attendanceService.getTodayAttendance(userId),
        _attendanceService.getAttendanceHistory(userId),
      ]);

      _todayAttendance = results[0] as AttendanceModel?;
      _historyList = results[1] as List<AttendanceModel>;
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      _errorMessage = 'Gagal memuat data presensi: ${e.toString()}';
    } finally {
      _isLoadingToday = false;
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Request and verify current GPS position
  Future<LocationResult> fetchCurrentLocation() async {
    _isGettingLocation = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _locationService.getCurrentLocation();
      _currentLocationResult = result;
      if (!result.isSuccess) {
        _errorMessage = result.errorMessage;
      }
      return result;
    } catch (e) {
      final fail = LocationResult.failure(
        errorMessage: 'Gagal mengambil koordinat GPS: ${e.toString()}',
      );
      _currentLocationResult = fail;
      _errorMessage = fail.errorMessage;
      return fail;
    } finally {
      _isGettingLocation = false;
      notifyListeners();
    }
  }

  /// Submits verified attendance to Firebase / Local Service
  Future<AttendanceModel?> submitAttendance(UserModel user) async {
    // 1. Guard against duplicate check-in
    if (hasCheckedInToday) {
      _errorMessage = 'Anda sudah melakukan presensi hari ini pada pukul ${_todayAttendance?.checkInTime}.';
      notifyListeners();
      return null;
    }

    // 2. Validate location exists
    final location = _currentLocationResult;
    if (location == null) {
      _errorMessage = 'Lokasi GPS belum didapatkan. Silakan periksa izin lokasi Anda.';
      notifyListeners();
      return null;
    }

    _isSubmittingCheckIn = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newRecord = await _attendanceService.submitCheckIn(
        user: user,
        latitude: location.latitude,
        longitude: location.longitude,
        locationName: location.locationName,
      );

      _todayAttendance = newRecord;

      // Update history list immediately
      _historyList.removeWhere((r) => r.id == newRecord.id);
      _historyList.insert(0, newRecord);

      _isSubmittingCheckIn = false;
      notifyListeners();
      return newRecord;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isSubmittingCheckIn = false;
      notifyListeners();
      return null;
    }
  }

  /// Submits verified attendance check-out to Firebase / Local Service
  Future<AttendanceModel?> submitCheckOut(UserModel user) async {
    if (!hasCheckedInToday) {
      _errorMessage = 'Anda belum melakukan presensi masuk (check-in) hari ini.';
      notifyListeners();
      return null;
    }

    if (hasCheckedOutToday) {
      _errorMessage = 'Anda sudah melakukan presensi keluar (check-out) hari ini pada pukul ${_todayAttendance?.checkOutTime}.';
      notifyListeners();
      return null;
    }

    final location = _currentLocationResult;
    if (location == null) {
      _errorMessage = 'Lokasi GPS belum didapatkan. Silakan periksa izin lokasi Anda.';
      notifyListeners();
      return null;
    }

    _isSubmittingCheckOut = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedRecord = await _attendanceService.submitCheckOut(
        user: user,
        latitude: location.latitude,
        longitude: location.longitude,
        locationName: location.locationName,
      );

      _todayAttendance = updatedRecord;

      // Update history list item immediately
      final index = _historyList.indexWhere((r) => r.id == updatedRecord.id);
      if (index != -1) {
        _historyList[index] = updatedRecord;
      } else {
        _historyList.insert(0, updatedRecord);
      }

      _isSubmittingCheckOut = false;
      notifyListeners();
      return updatedRecord;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isSubmittingCheckOut = false;
      notifyListeners();
      return null;
    }
  }

  /// Refreshes the history records
  Future<void> refreshHistory(String userId) async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      _historyList = await _attendanceService.getAttendanceHistory(userId);
      // Also update today's status
      _todayAttendance = await _attendanceService.getTodayAttendance(userId);
    } catch (e) {
      _errorMessage = 'Gagal memperbarui riwayat presensi.';
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  void clearLocation() {
    _currentLocationResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
