import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../app/screens.dart';
import '../../../core/theme/rayyan_colors.dart';
import '../../../core/widgets/rayyan_symbol.dart';
import '../../../core/services/firestore_database_service.dart';

// Use the same provider defined in device_scan_qr_screen.dart if needed, 
// or define it here if it's simpler. Assuming we can just create it.
final firestoreServiceProvider = Provider((ref) => FirestoreDatabaseService());

class DeviceManualEntryScreen extends ConsumerStatefulWidget {
  const DeviceManualEntryScreen({super.key, required this.onNavigate});

  final void Function(AppScreen) onNavigate;

  @override
  ConsumerState<DeviceManualEntryScreen> createState() => _DeviceManualEntryScreenState();
}

class _DeviceManualEntryScreenState extends ConsumerState<DeviceManualEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isProcessing = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitSerialNumber() async {
    final rawSerialNumber = _controller.text.trim();
    if (rawSerialNumber.length < 12) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.invalidSerialNumberLength;
      });
      return;
    }

    final serialNumber = _formatMacAddress(rawSerialNumber);

    setState(() {
      _isProcessing = true;
      _errorMessage = '';
    });

    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        setState(() {
          _isProcessing = false;
          _errorMessage = AppLocalizations.of(context)!.userNotAuthenticated;
        });
        return;
      }

      final firestoreService = ref.read(firestoreServiceProvider);
      final status = await firestoreService.registerDevice(serialNumber, currentUserId);

      if (!mounted) return;

      switch (status) {
        case DeviceRegistrationStatus.success:
          widget.onNavigate(AppScreen.dashboard);
          break;
        case DeviceRegistrationStatus.notFound:
          setState(() {
            _errorMessage = AppLocalizations.of(context)!.invalidSerialNumber;
          });
          break;
        case DeviceRegistrationStatus.alreadyRegistered:
          setState(() {
            _errorMessage = AppLocalizations.of(context)!.deviceAlreadyRegistered;
          });
          break;
        case DeviceRegistrationStatus.error:
          setState(() {
            _errorMessage = AppLocalizations.of(context)!.registrationError;
          });
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.unexpectedError;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          onPressed: () => widget.onNavigate(AppScreen.deviceScanQr),
        ),
        title: Text(
          l10n.connectDevice,
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white : Colors.black87,
              size: 20,
            ),
            onPressed: () => widget.onNavigate(AppScreen.deviceList),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

                          // Toggle Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? RayyanColors.cardDark
                                    : RayyanColors.onboardCardLight,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          widget.onNavigate(AppScreen.deviceScanQr),
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            l10n.scanQr,
                                            style: GoogleFonts.manrope(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white54
                                                  : Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? RayyanColors.surfaceDark
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          if (!isDark)
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.05,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          l10n.manualEntry,
                                          style: GoogleFonts.manrope(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: RayyanColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              l10n.enterApplianceNumber,
                              style: GoogleFonts.manrope(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black87,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              l10n.typeSerialCode,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  l10n.whereIsSerialNumber,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: RayyanColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: RayyanColors.primary,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Custom Mac Address Input
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Column(
                              children: [
                                MacAddressInput(controller: _controller),
                                if (_errorMessage.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      _errorMessage,
                                      style: TextStyle(
                                        color: RayyanColors.critical,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.macAddressFormat,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: isDark ? Colors.white30 : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Bottom Button
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 24.0,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isProcessing ? null : _submitSerialNumber,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: RayyanColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isProcessing
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            l10n.confirm,
                                            style: GoogleFonts.manrope(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.check_circle_outline,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatMacAddress(String raw) {
    String formatted = '';
    for (int i = 0; i < raw.length; i++) {
      formatted += raw[i];
      if (i % 2 == 1 && i != raw.length - 1) {
        formatted += ':';
      }
    }
    return formatted;
  }
}

class MacAddressInput extends StatefulWidget {
  final TextEditingController controller;
  const MacAddressInput({super.key, required this.controller});

  @override
  State<MacAddressInput> createState() => _MacAddressInputState();
}

class _MacAddressInputState extends State<MacAddressInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
    _focusNode.addListener(_update);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    _focusNode.removeListener(_update);
    _focusNode.dispose();
    super.dispose();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    List<Widget> blocks = [];
    for (int i = 0; i < 6; i++) {
      String blockText = '';
      if (text.length > i * 2) {
        int endIndex = (i * 2 + 2 <= text.length) ? i * 2 + 2 : text.length;
        blockText = text.substring(i * 2, endIndex);
      }
      
      bool isFocused = _focusNode.hasFocus && (text.length ~/ 2 == i || (text.length == 12 && i == 5));
      
      blocks.add(
        Container(
          width: 40,
          height: 54,
          decoration: BoxDecoration(
            color: isDark ? RayyanColors.surfaceDark : RayyanColors.onboardCardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFocused ? RayyanColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            blockText,
            style: GoogleFonts.manrope(
              fontSize: 18,
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      );
      
      if (i < 5) {
        blocks.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              ':',
              style: GoogleFonts.manrope(
                fontSize: 20,
                color: isDark ? Colors.white54 : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        );
      }
    }

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: blocks,
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  _MacAddressFormatter(),
                ],
                autocorrect: false,
                enableSuggestions: false,
                cursorColor: Colors.transparent,
                style: const TextStyle(color: Colors.transparent),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacAddressFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.toUpperCase().replaceAll(RegExp(r'[^0-9A-Z]'), '');
    
    if (newText.length > 12) {
      newText = newText.substring(0, 12);
    }
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
