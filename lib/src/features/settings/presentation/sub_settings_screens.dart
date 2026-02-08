import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/screens.dart';
import '../../../core/models/hydroponic/settings_model.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/hydroponic_database_service.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/utils/value_formatter.dart';
import '../../../core/widgets/aqua_header.dart';
import '../../../core/widgets/aqua_symbol.dart';

class AccountSecurityScreen extends ConsumerStatefulWidget {
  const AccountSecurityScreen({super.key, required this.onNavigate});
  final ValueChanged<AppScreen> onNavigate;

  @override
  ConsumerState<AccountSecurityScreen> createState() =>
      _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends ConsumerState<AccountSecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(_onFieldChanged);
    _newPasswordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;

    setState(() => _isLoading = true);
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final user = authService.currentUser;
      if (user != null && user.email != null) {
        await authService.reauthenticateUser(user.email!, current);
        await authService.updatePassword(newPass);

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Password updated successfully'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _currentPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final message = e is AuthException ? e.message : 'Something went wrong';
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AquaHeader(
            title: 'Account Security',
            onBack: () => widget.onNavigate(AppScreen.settings),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _Card(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Change Password',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 16),
                          _Field(
                            label: 'Current Password',
                            obscure: !_currentPasswordVisible,
                            controller: _currentPasswordController,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please enter your current password'
                                : null,
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _currentPasswordVisible =
                                    !_currentPasswordVisible,
                              ),
                              icon: AquaSymbol(
                                _currentPasswordVisible
                                    ? 'visibility'
                                    : 'visibility_off',
                                color: AquaColors.slate400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            label: 'New Password',
                            obscure: !_newPasswordVisible,
                            controller: _newPasswordController,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter a new password';
                              }
                              if (v.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () =>
                                    _newPasswordVisible = !_newPasswordVisible,
                              ),
                              icon: AquaSymbol(
                                _newPasswordVisible
                                    ? 'visibility'
                                    : 'visibility_off',
                                color: AquaColors.slate400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            label: 'Confirm New Password',
                            obscure: !_confirmPasswordVisible,
                            controller: _confirmPasswordController,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please confirm your new password';
                              }
                              if (v != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _confirmPasswordVisible =
                                    !_confirmPasswordVisible,
                              ),
                              icon: AquaSymbol(
                                _confirmPasswordVisible
                                    ? 'visibility'
                                    : 'visibility_off',
                                color: AquaColors.slate400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _updatePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AquaColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _isLoading ? 'Updating...' : 'Update Password',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SensorCalibrationScreen extends StatelessWidget {
  const SensorCalibrationScreen({super.key, required this.onNavigate});
  final ValueChanged<AppScreen> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AquaHeader(
            title: 'Sensor Calibration',
            onBack: () => onNavigate(AppScreen.settings),
            rightAction: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                'Log',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AquaColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AquaColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AquaColors.primary.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const AquaSymbol('info', color: AquaColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'For accurate readings, calibrate sensors monthly using standard buffer solutions.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AquaColors.slate600,
                                  height: 1.4,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SensorCard(
                    name: 'pH Sensor',
                    value: '6.2 pH',
                    lastCal: '2 days ago',
                    icon: 'water_ph',
                    color: AquaColors.info,
                    onTap: () => onNavigate(AppScreen.calibrationPh),
                  ),
                  const SizedBox(height: 16),
                  _SensorCard(
                    name: 'EC Sensor',
                    value: '1.8 mS',
                    lastCal: '5 days ago',
                    icon: 'bolt',
                    color: AquaColors.warning,
                    onTap: () => onNavigate(AppScreen.calibrationEc),
                  ),
                  const SizedBox(height: 16),
                  _SensorCard(
                    name: 'Water Temp',
                    value: '24.5°C',
                    lastCal: '1 week ago',
                    icon: 'device_thermostat',
                    color: AquaColors.critical,
                    onTap: () => onNavigate(AppScreen.calibrationTemp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThresholdsScreen extends ConsumerStatefulWidget {
  const ThresholdsScreen({super.key, required this.onNavigate});
  final ValueChanged<AppScreen> onNavigate;

  @override
  ConsumerState<ThresholdsScreen> createState() => _ThresholdsScreenState();
}

class _ThresholdsScreenState extends ConsumerState<ThresholdsScreen> {
  late final TextEditingController _tempHighController;
  late final TextEditingController _tempLowController;
  late final TextEditingController _phHighController;
  late final TextEditingController _phLowController;
  late final TextEditingController _ecHighController;
  late final TextEditingController _ecLowController;
  bool _hasPopulated = false;

  @override
  void initState() {
    super.initState();
    _tempHighController = TextEditingController();
    _tempLowController = TextEditingController();
    _phHighController = TextEditingController();
    _phLowController = TextEditingController();
    _ecHighController = TextEditingController();
    _ecLowController = TextEditingController();
  }

  @override
  void dispose() {
    _tempHighController.dispose();
    _tempLowController.dispose();
    _phHighController.dispose();
    _phLowController.dispose();
    _ecHighController.dispose();
    _ecLowController.dispose();
    super.dispose();
  }

  void _populateFromSettings(SettingsModel? settings) {
    if (settings == null || _hasPopulated) return;
    _hasPopulated = true;
    _tempHighController.text = (settings.tempHigh ?? 26.0).toStringAsFixed(1);
    _tempLowController.text = (settings.tempLow ?? 18.0).toStringAsFixed(1);
    _phHighController.text = (settings.phHigh ?? 6.5).toStringAsFixed(1);
    _phLowController.text = (settings.phLow ?? 5.5).toStringAsFixed(1);
    _ecHighController.text = (settings.ecHigh ?? 2.5).toStringAsFixed(1);
    _ecLowController.text = (settings.ecLow ?? 1.2).toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsAsync = ref.watch(settingsStreamProvider);
    final dbService = ref.read(hydroponicDatabaseServiceProvider);

    return Scaffold(
      body: Column(
        children: [
          AquaHeader(
            title: 'Operating Thresholds',
            onBack: () => widget.onNavigate(AppScreen.settings),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AquaColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AquaColors.primary.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const AquaSymbol('info', color: AquaColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'These limits control when fans, heaters, and pumps operate automatically.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? AquaColors.slate300
                                      : AquaColors.slate600,
                                  height: 1.4,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  settingsAsync.when(
                    data: (settings) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _populateFromSettings(settings);
                      });
                      return _ThresholdsForm(
                        tempHighController: _tempHighController,
                        tempLowController: _tempLowController,
                        phHighController: _phHighController,
                        phLowController: _phLowController,
                        ecHighController: _ecHighController,
                        ecLowController: _ecLowController,
                        onSave: () async {
                          final messenger = ScaffoldMessenger.maybeOf(context);
                          final tempHigh = double.tryParse(
                            _tempHighController.text,
                          );
                          final tempLow = double.tryParse(
                            _tempLowController.text,
                          );
                          final phHigh = double.tryParse(
                            _phHighController.text,
                          );
                          final phLow = double.tryParse(_phLowController.text);
                          final ecHigh = double.tryParse(
                            _ecHighController.text,
                          );
                          final ecLow = double.tryParse(_ecLowController.text);
                          final model = SettingsModel(
                            tempHigh: tempHigh ?? 26.0,
                            tempLow: tempLow ?? 18.0,
                            phHigh: phHigh ?? 6.5,
                            phLow: phLow ?? 5.5,
                            ecHigh: ecHigh ?? 2.5,
                            ecLow: ecLow ?? 1.2,
                          );
                          await dbService.updateSettings(model);
                          if (mounted && messenger != null) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Thresholds saved successfully'),
                              ),
                            );
                          }
                        },
                      );
                    },
                    loading: () => _ThresholdsForm(
                      tempHighController: _tempHighController,
                      tempLowController: _tempLowController,
                      phHighController: _phHighController,
                      phLowController: _phLowController,
                      ecHighController: _ecHighController,
                      ecLowController: _ecLowController,
                      isLoading: true,
                      onSave: () {},
                    ),
                    error: (_, __) => _ThresholdsForm(
                      tempHighController: _tempHighController,
                      tempLowController: _tempLowController,
                      phHighController: _phHighController,
                      phLowController: _phLowController,
                      ecHighController: _ecHighController,
                      ecLowController: _ecLowController,
                      isLoading: true,
                      onSave: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThresholdsForm extends StatelessWidget {
  const _ThresholdsForm({
    required this.tempHighController,
    required this.tempLowController,
    required this.phHighController,
    required this.phLowController,
    required this.ecHighController,
    required this.ecLowController,
    this.isLoading = false,
    required this.onSave,
  });

  final TextEditingController tempHighController;
  final TextEditingController tempLowController;
  final TextEditingController phHighController;
  final TextEditingController phLowController;
  final TextEditingController ecHighController;
  final TextEditingController ecLowController;
  final bool isLoading;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ThresholdField(
            label: 'Fan Limit (temp_high)',
            hint: '°C - Fan operating limit',
            controller: tempHighController,
            enabled: !isLoading,
            placeholder: ValueFormatter.nullPlaceholder,
          ),
          const SizedBox(height: 16),
          _ThresholdField(
            label: 'Heater Limit (temp_low)',
            hint: '°C - Heater operating limit',
            controller: tempLowController,
            enabled: !isLoading,
            placeholder: ValueFormatter.nullPlaceholder,
          ),
          const SizedBox(height: 16),
          _ThresholdField(
            label: 'pH Pump Limit (ph_high)',
            hint: 'pH - pH pump operating limit',
            controller: phHighController,
            enabled: !isLoading,
            placeholder: ValueFormatter.nullPlaceholder,
          ),
          const SizedBox(height: 16),
          _ThresholdField(
            label: 'pH Pump Limit (ph_low)',
            hint: 'pH - pH lower bound',
            controller: phLowController,
            enabled: !isLoading,
            placeholder: ValueFormatter.nullPlaceholder,
          ),
          const SizedBox(height: 16),
          _ThresholdField(
            label: 'Feeding Pump Limit (ec_high)',
            hint: 'mS/cm - Feeding pump off limit',
            controller: ecHighController,
            enabled: !isLoading,
            placeholder: ValueFormatter.nullPlaceholder,
          ),
          const SizedBox(height: 16),
          _ThresholdField(
            label: 'Feeding Pump Limit (ec_low)',
            hint: 'mS/cm - Feeding pump operating limit',
            controller: ecLowController,
            enabled: !isLoading,
            placeholder: ValueFormatter.nullPlaceholder,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AquaColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isLoading ? ValueFormatter.nullPlaceholder : 'Save Thresholds',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThresholdField extends StatelessWidget {
  const _ThresholdField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.enabled,
    required this.placeholder,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool enabled;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isDark ? AquaColors.slate400 : AquaColors.slate500,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: enabled ? hint : placeholder,
            filled: true,
            fillColor: isDark ? AquaColors.surfaceDark : AquaColors.slate100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : AquaColors.slate200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : AquaColors.slate200,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PhCalibrationScreen extends StatefulWidget {
  const PhCalibrationScreen({super.key, required this.onNavigate});
  final ValueChanged<AppScreen> onNavigate;
  @override
  State<PhCalibrationScreen> createState() => _PhCalibrationScreenState();
}

class _PhCalibrationScreenState extends State<PhCalibrationScreen> {
  int step = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AquaHeader(
            title: 'pH Calibration',
            onBack: () => widget.onNavigate(AppScreen.sensorCalibration),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
              child: Column(
                children: [
                  Text(
                    'Current Reading'.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AquaColors.slate400,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '6.2',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: AquaColors.info,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'pH',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AquaColors.slate500,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AquaColors.slate100,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AquaColors.nature,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Signal Stable',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AquaColors.slate500,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Calibration Wizard',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 16),
                        _WizardStep(
                          idx: 0,
                          step: step,
                          title: 'Prepare Buffer 7.0',
                          subtitle:
                              'Clean probe with distilled water and place in pH 7.0 solution.',
                        ),
                        _WizardStep(
                          idx: 1,
                          step: step,
                          title: 'Prepare Buffer 4.0',
                          subtitle:
                              'Rinse probe again and place in pH 4.0 solution.',
                        ),
                        _WizardStep(
                          idx: 2,
                          step: step,
                          title: 'Finalize',
                          subtitle:
                              'Save new calibration data to flash memory.',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              if (step < 2) {
                                setState(() => step += 1);
                              } else {
                                widget.onNavigate(AppScreen.sensorCalibration);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AquaColors.info,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              step == 0
                                  ? 'Calibrate Point 7.0'
                                  : step == 1
                                  ? 'Calibrate Point 4.0'
                                  : 'Save Calibration',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EcCalibrationScreen extends StatelessWidget {
  const EcCalibrationScreen({super.key, required this.onNavigate});
  final ValueChanged<AppScreen> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AquaHeader(
            title: 'EC Calibration',
            onBack: () => onNavigate(AppScreen.sensorCalibration),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
              child: Column(
                children: [
                  Text(
                    'Current Conductivity'.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AquaColors.slate400,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1.8',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: AquaColors.warning,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'mS',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AquaColors.slate500,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _Card(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AquaColors.warning.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AquaColors.warning.withValues(alpha: 0.20),
                            ),
                          ),
                          child: Row(
                            children: [
                              const AquaSymbol(
                                'warning',
                                color: AquaColors.warning,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Ensure the probe is clean and free of organic buildup before calibrating.',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AquaColors.warning),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SelectRow(
                          title: 'Calibration Standard',
                          value: '1.413 mS/cm (Standard)',
                        ),
                        const SizedBox(height: 12),
                        _SelectRow(
                          title: 'Temperature Compensation',
                          value: '2.0% / °C',
                          trailing: 'Fixed',
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AquaColors.warning,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Start 1-Point Calibration',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              onNavigate(AppScreen.sensorCalibration),
                          child: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AquaColors.slate500,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TempCalibrationScreen extends StatefulWidget {
  const TempCalibrationScreen({super.key, required this.onNavigate});
  final ValueChanged<AppScreen> onNavigate;
  @override
  State<TempCalibrationScreen> createState() => _TempCalibrationScreenState();
}

class _TempCalibrationScreenState extends State<TempCalibrationScreen> {
  double offset = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AquaHeader(
            title: 'Temp Calibration',
            onBack: () => widget.onNavigate(AppScreen.sensorCalibration),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
              child: Column(
                children: [
                  Text(
                    'Sensor Reading'.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AquaColors.slate400,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (24.5 + offset).toStringAsFixed(1),
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: AquaColors.critical,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          '°C',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AquaColors.slate500,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Raw Value: 24.5°C',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AquaColors.slate500,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Manual Offset Adjustment',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use a certified reference thermometer to determine the offset required.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AquaColors.slate500),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AquaColors.slate100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _RoundButton(
                                icon: 'remove',
                                onTap: () => setState(
                                  () => offset = double.parse(
                                    (offset - 0.1).toStringAsFixed(1),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    offset > 0
                                        ? '+${offset.toStringAsFixed(1)}'
                                        : offset.toStringAsFixed(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                  Text(
                                    'OFFSET °C',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AquaColors.slate400,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.4,
                                        ),
                                  ),
                                ],
                              ),
                              _RoundButton(
                                icon: 'add',
                                onTap: () => setState(
                                  () => offset = double.parse(
                                    (offset + 0.1).toStringAsFixed(1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () =>
                                widget.onNavigate(AppScreen.sensorCalibration),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AquaColors.critical,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Apply Offset',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FirmwareUpdateScreen extends StatelessWidget {
  const FirmwareUpdateScreen({super.key, required this.onNavigate});
  final ValueChanged<AppScreen> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AquaHeader(
            title: 'Firmware Update',
            onBack: () => onNavigate(AppScreen.settings),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
              child: Column(
                children: [
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      color: AquaColors.slate100,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: AquaSymbol(
                            'system_update',
                            size: 64,
                            color: AquaColors.slate300,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AquaColors.nature,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AquaColors.backgroundLight,
                                width: 4,
                              ),
                            ),
                            child: const Center(
                              child: AquaSymbol('check', color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'System is Up to Date',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Installed Version: v2.4.1',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AquaColors.slate500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Changelog v2.4.1',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Released Oct 24, 2023',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AquaColors.slate400),
                        ),
                        const SizedBox(height: 16),
                        _Bullet('Improved pH sensor stability algorithm'),
                        _Bullet('New "Eco Mode" for lighting schedule'),
                        _Bullet('Bug fixes for WiFi reconnection logic'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Check for Updates',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key, required this.onNavigate});
  final ValueChanged<AppScreen> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AquaHeader(
            title: 'Notification Settings',
            onBack: () => onNavigate(AppScreen.settings),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Section('Delivery Methods'),
                  _Card(
                    child: Column(
                      children: const [
                        _ToggleItem(
                          title: 'Push Notifications',
                          subtitle: 'Receive alerts on this device',
                          initial: true,
                        ),
                        _DividerLine(),
                        _ToggleItem(
                          title: 'Email Notifications',
                          subtitle: 'Send summaries to registered email',
                          initial: false,
                        ),
                        _DividerLine(),
                        _ToggleItem(
                          title: 'SMS Alerts',
                          subtitle: 'Critical alerts via text message',
                          initial: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Section('Alert Types'),
                  _Card(
                    child: Column(
                      children: const [
                        _ToggleItem(
                          title: 'Critical System Failures',
                          subtitle: 'Pump failure, leak detection, power loss',
                          initial: true,
                        ),
                        _DividerLine(),
                        _ToggleItem(
                          title: 'Parameter Warnings',
                          subtitle: 'pH or EC deviation outside safe range',
                          initial: true,
                        ),
                        _DividerLine(),
                        _ToggleItem(
                          title: 'Harvest Reminders',
                          subtitle: 'Scheduled maintenance and harvest time',
                          initial: true,
                        ),
                        _DividerLine(),
                        _ToggleItem(
                          title: 'AI Insights',
                          subtitle: 'Daily growth tips and predictions',
                          initial: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Section('Schedule'),
                  _Card(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quiet Hours',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  'Mute non-critical alerts',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AquaColors.slate500),
                                ),
                              ],
                            ),
                            Container(
                              width: 48,
                              height: 28,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AquaColors.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: const [
                            Expanded(
                              child: _TimeBox(
                                label: 'Start Time',
                                value: '10:00 PM',
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _TimeBox(
                                label: 'End Time',
                                value: '07:00 AM',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AquaColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AquaColors.slate200,
        ),
      ),
      child: child,
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    this.obscure = false,
    this.controller,
    this.validator,
    this.suffixIcon,
  });
  final String label;
  final bool obscure;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AquaColors.slate500,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            hintText: '',
            filled: true,
            fillColor: isDark ? AquaColors.surfaceDark : AquaColors.slate100,
            suffixIcon: suffixIcon,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AquaColors.critical,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AquaColors.critical,
                width: 1.2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : AquaColors.slate200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : AquaColors.slate200,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({
    required this.name,
    required this.value,
    required this.lastCal,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String name;
  final String value;
  final String lastCal;
  final String icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AquaColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AquaColors.slate200,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AquaColors.surfaceDark
                          : AquaColors.slate100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: AquaSymbol(icon, color: color)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Current: $value',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AquaColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AquaColors.surfaceDark : AquaColors.slate100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Last: $lastCal'.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AquaColors.slate500,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Calibrate Now',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WizardStep extends StatelessWidget {
  const _WizardStep({
    required this.idx,
    required this.step,
    required this.title,
    required this.subtitle,
  });
  final int idx;
  final int step;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    final active = step == idx;
    final done = step >= idx;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: done ? AquaColors.info : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: done ? AquaColors.info : AquaColors.slate200,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${idx + 1}',
                    style: TextStyle(
                      color: done ? Colors.white : AquaColors.slate400,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              if (idx < 2)
                Container(
                  width: 2,
                  height: 40,
                  color: step >= idx + 1
                      ? AquaColors.info
                      : AquaColors.slate200,
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: active ? null : AquaColors.slate400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AquaColors.slate500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectRow extends StatelessWidget {
  const _SelectRow({required this.title, required this.value, this.trailing});
  final String title;
  final String value;
  final String? trailing;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AquaColors.slate500,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AquaColors.surfaceDark : AquaColors.slate100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : AquaColors.slate200,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AquaColors.slate400,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});
  final String icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? AquaColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AquaColors.slate200,
          ),
        ),
        child: Center(child: AquaSymbol(icon)),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const AquaSymbol('check_circle', color: AquaColors.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AquaColors.slate600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatefulWidget {
  const _ToggleItem({
    required this.title,
    required this.subtitle,
    required this.initial,
  });
  final String title;
  final String subtitle;
  final bool initial;
  @override
  State<_ToggleItem> createState() => _ToggleItemState();
}

class _ToggleItemState extends State<_ToggleItem> {
  late bool isOn = widget.initial;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => isOn = !isOn),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AquaColors.slate500),
                  ),
                ],
              ),
            ),
            Container(
              width: 48,
              height: 28,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isOn ? AquaColors.primary : AquaColors.slate200,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Align(
                alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: Color(0x11FFFFFF));
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AquaColors.slate400,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AquaColors.slate400,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AquaColors.surfaceDark : AquaColors.slate100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}
