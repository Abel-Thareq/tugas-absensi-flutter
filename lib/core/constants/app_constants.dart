class AppConstants {
  // App metadata
  static const String appName = 'Presensi Pegawai';
  static const String appVersion = 'v2.4 Enterprise';

  // Company default info
  static const String companyName = 'PT Inovasi Digital Nusantara';
  static const String defaultOfficeName = 'Headquarters • 3rd Floor';
  static const double defaultOfficeLatitude = -7.470474;
  static const double defaultOfficeLongitude = 110.217712;
  static const double officeGeofenceRadiusMeters = 150.0;

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String attendanceCollection = 'attendance';

  // Default demo employee credentials for immediate testing
  static const String demoEmail = 'abel@perusahaan.com';
  static const String demoPassword = 'password123';
  static const String demoEmployeeId = 'EMP-2026-084';
  static const String demoName = 'Abel';
  static const String demoPosition = 'Senior Mobile Engineer';
  static const String demoDepartment = 'Product & Mobile Engineering';
}
