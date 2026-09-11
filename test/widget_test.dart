import 'package:flutter_test/flutter_test.dart';
import 'package:presensi_app/models/user_model.dart';
import 'package:presensi_app/models/attendance_model.dart';

void main() {
  group('Attendance & User Model Tests', () {
    test('UserModel serialization and copyWith', () {
      final user = UserModel(
        id: 'usr_test_1',
        name: 'Abel',
        employeeId: 'EMP-2026-084',
        email: 'abel@perusahaan.com',
        position: 'Senior Mobile Engineer',
        department: 'Product & Mobile Engineering',
        createdAt: DateTime(2026, 9, 11),
      );

      final map = user.toMap();
      expect(map['name'], 'Abel');
      expect(map['employeeId'], 'EMP-2026-084');

      final fromMap = UserModel.fromMap(map);
      expect(fromMap.id, 'usr_test_1');
      expect(fromMap.email, 'abel@perusahaan.com');
    });

    test('AttendanceModel duplicate key & coordinate validation', () {
      final now = DateTime(2026, 9, 11, 8, 3);
      final record = AttendanceModel(
        id: 'att_usr_test_1_20260911',
        userId: 'usr_test_1',
        employeeId: 'EMP-2026-084',
        date: '2026-09-11',
        checkInTime: '08:03 AM',
        status: 'Present',
        latitude: -7.470474,
        longitude: 110.217712,
        locationName: 'Headquarters • 3rd Floor',
        createdAt: now,
      );

      expect(record.coordinatesShort, '-7.47047, 110.21771');
      expect(record.status, 'Present');

      final map = record.toMap();
      final fromMap = AttendanceModel.fromMap(map);
      expect(fromMap.date, '2026-09-11');
      expect(fromMap.checkInTime, '08:03 AM');
      expect(fromMap.latitude, -7.470474);
      expect(fromMap.longitude, 110.217712);
    });
  });
}
