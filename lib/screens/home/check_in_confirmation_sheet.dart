import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/location_service.dart';

class CheckInConfirmationSheet extends StatefulWidget {
  final LocationResult locationResult;
  final Future<void> Function() onConfirm;
  final bool isCheckOut;

  const CheckInConfirmationSheet({
    super.key,
    required this.locationResult,
    required this.onConfirm,
    this.isCheckOut = false,
  });

  @override
  State<CheckInConfirmationSheet> createState() => _CheckInConfirmationSheetState();
}

class _CheckInConfirmationSheetState extends State<CheckInConfirmationSheet> {
  bool _isSubmitting = false;

  Future<void> _handleConfirm() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onConfirm();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dateStr = DateFormat('d MMMM yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);
    final coordsStr =
        '${widget.locationResult.latitude.toStringAsFixed(6)}, ${widget.locationResult.longitude.toStringAsFixed(6)}';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            widget.isCheckOut ? 'Konfirmasi Check-out' : 'Konfirmasi Check-in',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.isCheckOut
                ? 'Pastikan jam dan koordinat presensi pulang sudah sesuai.'
                : 'Pastikan jam dan koordinat presensi masuk sudah sesuai.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildRow(
                  label: 'Tanggal',
                  icon: Icons.calendar_today_outlined,
                  value: dateStr,
                ),
                const Divider(height: 18),
                _buildRow(
                  label: widget.isCheckOut ? 'Jam Pulang' : 'Jam Masuk',
                  icon: Icons.access_time,
                  value: timeStr,
                ),
                const Divider(height: 18),
                _buildRow(
                  label: 'Lokasi GPS',
                  icon: Icons.pin_drop_outlined,
                  value: coordsStr,
                  isMonospace: true,
                ),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Text(
                          'Tipe Presensi',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.successBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isCheckOut ? Icons.logout : Icons.login,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.isCheckOut ? 'Check-out (Pulang)' : 'Check-in (Masuk)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Security audit note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_user_outlined, size: 16, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data tersinkronisasi dengan Firebase Cloud Firestore dan waktu server yang tidak dapat dimanipulasi.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Buttons
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleConfirm,
            child: _isSubmitting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(widget.isCheckOut ? 'Menyimpan check-out...' : 'Menyimpan check-in...'),
                    ],
                  )
                : Text(widget.isCheckOut ? 'Konfirmasi Check-out' : 'Konfirmasi Check-in'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required IconData icon,
    required String value,
    bool isMonospace = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: isMonospace ? 'monospace' : null,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
