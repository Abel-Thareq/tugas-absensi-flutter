import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/location_service.dart';

class LocationVerificationSheet extends StatefulWidget {
  final Future<LocationResult> Function() onAcquireLocation;
  final VoidCallback onContinue;

  const LocationVerificationSheet({
    super.key,
    required this.onAcquireLocation,
    required this.onContinue,
  });

  @override
  State<LocationVerificationSheet> createState() => _LocationVerificationSheetState();
}

class _LocationVerificationSheetState extends State<LocationVerificationSheet> {
  bool _isLoading = true;
  LocationResult? _locationResult;

  @override
  void initState() {
    super.initState();
    _startLocationAcquisition();
  }

  Future<void> _startLocationAcquisition() async {
    setState(() {
      _isLoading = true;
    });

    final result = await widget.onAcquireLocation();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _locationResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          const SizedBox(height: 20),

          if (_isLoading) ...[
            // Loading State
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Getting your location...',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Acquiring high-accuracy GPS coordinates to verify physical presence.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
          ] else if (_locationResult != null && _locationResult!.isSuccess) ...[
            // Success State
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.successBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.successBorder),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.success,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location verified',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your current location will be recorded with this attendance.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Coordinates Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Latitude',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _locationResult!.latitude.toStringAsFixed(6),
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Longitude',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _locationResult!.longitude.toStringAsFixed(6),
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Location available',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onContinue();
              },
              child: const Text('Continue'),
            ),
          ] else ...[
            // Error / Permission Denied State
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.errorBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.errorBorder),
                  ),
                  child: const Icon(
                    Icons.location_off_outlined,
                    color: AppColors.error,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Required',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _locationResult?.errorMessage ?? 'Cannot acquire coordinates.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_locationResult?.isPermissionDeniedForever ?? false) ...[
              ElevatedButton(
                onPressed: () async {
                  await LocationService().openAppSettings();
                  _startLocationAcquisition();
                },
                child: const Text('Open App Settings'),
              ),
            ] else if (_locationResult?.isServiceDisabled ?? false) ...[
              ElevatedButton(
                onPressed: () async {
                  await LocationService().openLocationSettings();
                  _startLocationAcquisition();
                },
                child: const Text('Enable Location Service'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _startLocationAcquisition,
                child: const Text('Retry Location Check'),
              ),
            ],
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ],
      ),
    );
  }
}
