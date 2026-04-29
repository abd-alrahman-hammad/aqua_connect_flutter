import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/screens.dart';
import '../../../core/theme/rayyan_colors.dart';
import '../../../core/widgets/rayyan_symbol.dart';
import 'widgets/device_list_item.dart';

class DeviceListScreen extends ConsumerStatefulWidget {
  const DeviceListScreen({super.key, required this.onNavigate});

  final void Function(AppScreen) onNavigate;

  @override
  ConsumerState<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends ConsumerState<DeviceListScreen> {
  String _selectedDevice = 'Smart Hydroponic System';

  final List<Map<String, dynamic>> _devices = [
    {
      'name': 'Smart Hydroponic System',
      'icon': Icons.energy_savings_leaf_outlined,
    },
    {'name': 'Vertical Farming Unit', 'icon': Icons.layers_outlined},
    {'name': 'Smart Grow Tent', 'icon': Icons.home_outlined},
    {'name': 'Automated Greenhouse', 'icon': Icons.domain_outlined},
    {'name': 'Aquaponics System', 'icon': Icons.water_outlined},
    {'name': 'Indoor Herb Garden', 'icon': Icons.local_florist_outlined},
    {'name': 'Smart Composter', 'icon': Icons.recycling_outlined},
    {'name': 'Smart Irrigation Hub', 'icon': Icons.water_drop_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          onPressed: () => widget.onNavigate(AppScreen.addDevice),
        ),
        title: Text(
          'Select Category',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? RayyanColors.cardDark : RayyanColors.onboardCardLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: GoogleFonts.manrope(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for device...',
                  hintStyle: GoogleFonts.manrope(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.white54 : Colors.black45,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Text(
              'SELECT APPLIANCE TYPE',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : Colors.black54,
                letterSpacing: 1.2,
              ),
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              itemCount: _devices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final device = _devices[index];
                final isSelected = _selectedDevice == device['name'];

                return DeviceListItem(
                  device: device,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      _selectedDevice = device['name'] as String;
                    });
                  },
                );
              },
            ),
          ),

          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => widget.onNavigate(AppScreen.wifiInstructions),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RayyanColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'NEXT',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
