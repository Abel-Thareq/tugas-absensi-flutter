import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/attendance_model.dart';

class CheckInSuccessDialog extends StatelessWidget {
  final AttendanceModel attendance;
  final VoidCallback onViewHistory;
  final bool isCheckOut;

  const CheckInSuccessDialog({
    super.key,
    required this.attendance,
    required this.onViewHistory,
    this.isCheckOut = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Checkmark Badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.successBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.successBorder, width: 1.5),
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              isCheckOut ? 'Check-out Berhasil' : 'Presensi Masuk Berhasil',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              attendance.formattedDisplayDayDate,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Summary List
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jam Check-in',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      Text(
                        attendance.checkInTime,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (isCheckOut && attendance.checkOutTime != null) ...[
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Jam Check-out',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        Text(
                          attendance.checkOutTime!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Status Verifikasi GPS',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      Text(
                        'Terverifikasi Valid',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isCheckOut ? 'Koordinat Pulang' : 'Koordinat Masuk',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      Text(
                        isCheckOut && attendance.checkOutCoordinatesShort.isNotEmpty
                            ? attendance.checkOutCoordinatesShort
                            : attendance.coordinatesShort,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Actions
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onViewHistory();
              },
              child: const Text('Lihat Riwayat Presensi'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }
}
