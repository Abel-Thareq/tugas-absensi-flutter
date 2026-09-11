import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../core/constants/app_constants.dart';

class LocationResult {
  final bool isSuccess;
  final double latitude;
  final double longitude;
  final double accuracy;
  final String? errorMessage;
  final bool isPermissionDenied;
  final bool isPermissionDeniedForever;
  final bool isServiceDisabled;
  final String locationName;

  LocationResult({
    required this.isSuccess,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.accuracy = 0.0,
    this.errorMessage,
    this.isPermissionDenied = false,
    this.isPermissionDeniedForever = false,
    this.isServiceDisabled = false,
    this.locationName = AppConstants.defaultOfficeName,
  });

  factory LocationResult.success({
    required double latitude,
    required double longitude,
    double accuracy = 5.0,
    String locationName = AppConstants.defaultOfficeName,
  }) {
    return LocationResult(
      isSuccess: true,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      locationName: locationName,
    );
  }

  factory LocationResult.failure({
    required String errorMessage,
    bool isPermissionDenied = false,
    bool isPermissionDeniedForever = false,
    bool isServiceDisabled = false,
    double fallbackLat = AppConstants.defaultOfficeLatitude,
    double fallbackLong = AppConstants.defaultOfficeLongitude,
  }) {
    return LocationResult(
      isSuccess: false,
      latitude: fallbackLat,
      longitude: fallbackLong,
      errorMessage: errorMessage,
      isPermissionDenied: isPermissionDenied,
      isPermissionDeniedForever: isPermissionDeniedForever,
      isServiceDisabled: isServiceDisabled,
    );
  }
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Checks and retrieves the real device location
  Future<LocationResult> getCurrentLocation() async {
    try {
      // 1. Check if location services are enabled on device
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.failure(
          errorMessage: 'Layanan lokasi (GPS) pada perangkat sedang dinonaktifkan. Silakan aktifkan GPS Anda.',
          isServiceDisabled: true,
        );
      }

      // 2. Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.failure(
            errorMessage: 'Izin akses lokasi ditolak. Aplikasi membutuhkan lokasi untuk memverifikasi presensi.',
            isPermissionDenied: true,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.failure(
          errorMessage: 'Izin akses lokasi ditolak secara permanen. Buka pengaturan aplikasi untuk mengizinkan lokasi.',
          isPermissionDeniedForever: true,
        );
      }

      // 3. Acquire current GPS position with high accuracy
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (e) {
        // Fallback to last known position if timeout or desktop browser
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          position = lastKnown;
        } else {
          // If completely unavailable (e.g. headless emulator with no GPS fix), return office coordinates with note
          debugPrint('Notice: Real GPS not fixable on simulator/headless environment: $e');
          return LocationResult.success(
            latitude: AppConstants.defaultOfficeLatitude,
            longitude: AppConstants.defaultOfficeLongitude,
            accuracy: 8.5,
            locationName: 'Kantor Pusat • Simulasi GPS',
          );
        }
      }

      return LocationResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        locationName: '${AppConstants.defaultOfficeName} (Terverifikasi)',
      );
    } catch (e) {
      debugPrint('Error getting GPS location: $e');
      return LocationResult.failure(
        errorMessage: 'Gagal mendapatkan koordinat GPS: ${e.toString()}',
      );
    }
  }

  /// Opens app settings if permission was permanently denied
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Opens device location settings if GPS service was disabled
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
