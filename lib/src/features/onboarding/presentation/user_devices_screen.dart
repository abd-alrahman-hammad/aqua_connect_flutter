import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/screens.dart';
import '../../../core/models/db/device_model.dart';
import '../../../core/services/firestore_database_service.dart';
import '../../../core/theme/rayyan_colors.dart';
import '../../../core/widgets/rayyan_symbol.dart';

class UserDevicesScreen extends ConsumerWidget {
  const UserDevicesScreen({super.key, required this.onNavigate});

  final void Function(AppScreen) onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userDevicesAsync = ref.watch(userDevicesProvider);
    final devices = userDevicesAsync.valueOrNull ?? [];
    final hasDevices = devices.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark
          ? RayyanColors.backgroundDark
          : RayyanColors.onboardBackgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: RayyanSymbol(
            'arrow_back_ios_new',
            color: isDark ? Colors.white : Colors.black87,
            size: 20,
          ),
          onPressed: () => onNavigate(AppScreen.addDevice),
        ),
        title: Text(
          'Your Appliances',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: hasDevices
            ? _buildDevicesList(context, isDark, devices)
            : _buildEmptyState(context, isDark),
      ),
    );
  }

  Widget _buildDevicesList(
    BuildContext context,
    bool isDark,
    List<DeviceModel> devices,
  ) {
    return ListView(
      children: devices
          .map(
            (device) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? RayyanColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : RayyanColors.slate200,
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? RayyanColors.surfaceDark
                            : RayyanColors.onboardCardLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.energy_savings_leaf_outlined,
                        color: RayyanColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name.isNotEmpty
                                ? device.name
                                : 'Smart Hydroponic System',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Connected',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: RayyanColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: RayyanColors.slate400,
                      ),
                      onPressed: () => onNavigate(AppScreen.dashboard),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? RayyanColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark
                  ? RayyanColors.surfaceDark
                  : RayyanColors.onboardCardLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: isDark
                  ? RayyanColors.primary
                  : RayyanColors.onboardIconTint,
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No appliances added',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your hydroponic journey by\nconnecting your first system.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => onNavigate(AppScreen.deviceList),
              style: ElevatedButton.styleFrom(
                backgroundColor: RayyanColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'ADD YOUR APPLIANCES',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
