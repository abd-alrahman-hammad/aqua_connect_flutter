
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../app/screens.dart';
import '../../../core/theme/rayyan_colors.dart';
import '../../../core/widgets/rayyan_symbol.dart';
import '../../../core/services/firestore_database_service.dart';

// Create a provider for FirestoreDatabaseService if it doesn't exist globally
// Assuming there is a general provider, but if not we can instantiate or get it.
final firestoreServiceProvider = Provider((ref) => FirestoreDatabaseService());

class DeviceScanQrScreen extends ConsumerStatefulWidget {
  final void Function(AppScreen) onNavigate;

  const DeviceScanQrScreen({super.key, required this.onNavigate});

  @override
  ConsumerState<DeviceScanQrScreen> createState() => _DeviceScanQrScreenState();
}

class _DeviceScanQrScreenState extends ConsumerState<DeviceScanQrScreen> {
  late final MobileScannerController _scannerController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final String scannedCode = barcodes.first.rawValue!;
      setState(() {
        _isProcessing = true;
      });

      try {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) {
          // Handle unauthenticated state if needed
          setState(() {
            _isProcessing = false;
          });
          return;
        }

        final firestoreService = ref.read(firestoreServiceProvider);
        final status = await firestoreService.registerDevice(scannedCode, currentUserId);

        if (!mounted) return;

        switch (status) {
          case DeviceRegistrationStatus.success:
            widget.onNavigate(AppScreen.dashboard);
            break;
          case DeviceRegistrationStatus.notFound:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.invalidQrCode),
                backgroundColor: RayyanColors.critical,
                behavior: SnackBarBehavior.floating,
              ),
            );
            break;
          case DeviceRegistrationStatus.alreadyRegistered:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.deviceAlreadyRegistered),
                backgroundColor: RayyanColors.critical,
                behavior: SnackBarBehavior.floating,
              ),
            );
            break;
          case DeviceRegistrationStatus.error:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.generalError),
                backgroundColor: RayyanColors.critical,
                behavior: SnackBarBehavior.floating,
              ),
            );
            break;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.unexpectedError),
              backgroundColor: RayyanColors.critical,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black, // Scanner usually looks best with black background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const RayyanSymbol(
            'arrow_back_ios_new',
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => widget.onNavigate(AppScreen.qrInstructions),
        ),
        title: Text(
          l10n.connectDevice,
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => widget.onNavigate(AppScreen.deviceList), // Cancel
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Feed
          MobileScanner(
            controller: _scannerController,
            fit: BoxFit.cover,
            onDetect: _handleBarcode,
          ),

          // Dark Overlay with Cutout (Simulated)
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.red, // This color will be cut out
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Stack(
              children: [
                // Top UI
                Positioned(
                  top: 24,
                  left: 24,
                  right: 24,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                l10n.scanQr,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: RayyanColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                widget.onNavigate(AppScreen.deviceManualEntry),
                            child: Container(
                              color: Colors.transparent,
                              child: Center(
                                child: Text(
                                  l10n.manualEntry,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Viewfinder Border (Centered)
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: _isProcessing 
                      ? const Center(child: CircularProgressIndicator(color: RayyanColors.primary))
                      : null,
                  ),
                ),

                // Bottom UI (Text and Flashlight)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.scanQrTitle,
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: Text(
                          l10n.scanQrSubtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      GestureDetector(
                        onTap: () async {
                          try {
                            await _scannerController.toggleTorch();
                          } catch (e) {
                            // ignore
                          }
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: RayyanColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.highlight,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
