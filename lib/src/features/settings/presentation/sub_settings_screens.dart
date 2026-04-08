import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/generated/app_localizations.dart';

import '../../../app/screens.dart';
import '../../../core/models/hydroponic/settings_model.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/hydroponic_database_service.dart';
import '../../../core/theme/rayyan_colors.dart';
import '../../../core/utils/value_formatter.dart';
import '../../../core/widgets/rayyan_header.dart';
import '../../../core/widgets/rayyan_symbol.dart';
import '../domain/notification_preferences.dart';

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
              title: Text(AppLocalizations.of(context)!.success),
              content: Text(
                AppLocalizations.of(context)!.passwordUpdatedSuccessfully,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _currentPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                  },
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final message = e is AuthException
            ? e.message
            : AppLocalizations.of(context)!.somethingWentWrong;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.error),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.ok),
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
          RayyanHeader(
            title: AppLocalizations.of(context)!.accountSecurityTitle,
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
                            AppLocalizations.of(context)!.changePasswordTitle,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 16),
                          _Field(
                            label: AppLocalizations.of(
                              context,
                            )!.currentPassword,
                            obscure: !_currentPasswordVisible,
                            controller: _currentPasswordController,
                            validator: (v) => (v == null || v.isEmpty)
                                ? AppLocalizations.of(
                                    context,
                                  )!.pleaseEnterCurrentPassword
                                : null,
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _currentPasswordVisible =
                                    !_currentPasswordVisible,
                              ),
                              icon: RayyanSymbol(
                                _currentPasswordVisible
                                    ? 'visibility'
                                    : 'visibility_off',
                                color: RayyanColors.slate400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            label: AppLocalizations.of(context)!.newPassword,
                            obscure: !_newPasswordVisible,
                            controller: _newPasswordController,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return AppLocalizations.of(
                                  context,
                                )!.pleaseEnterNewPassword;
                              }
                              if (v.length < 8) {
                                return AppLocalizations.of(
                                  context,
                                )!.passwordMinLength;
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () =>
                                    _newPasswordVisible = !_newPasswordVisible,
                              ),
                              icon: RayyanSymbol(
                                _newPasswordVisible
                                    ? 'visibility'
                                    : 'visibility_off',
                                color: RayyanColors.slate400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            label: AppLocalizations.of(
                              context,
                            )!.confirmNewPassword,
                            obscure: !_confirmPasswordVisible,
                            controller: _confirmPasswordController,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return AppLocalizations.of(
                                  context,
                                )!.pleaseConfirmPassword;
                              }
                              if (v != _newPasswordController.text) {
                                return AppLocalizations.of(
                                  context,
                                )!.passwordsMismatch;
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _confirmPasswordVisible =
                                    !_confirmPasswordVisible,
                              ),
                              icon: RayyanSymbol(
                                _confirmPasswordVisible
                                    ? 'visibility'
                                    : 'visibility_off',
                                color: RayyanColors.slate400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _updatePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: RayyanColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _isLoading
                                    ? AppLocalizations.of(context)!.updating
                                    : AppLocalizations.of(
                                        context,
                                      )!.updatePasswordButton,
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
          RayyanHeader(
            title: AppLocalizations.of(context)!.operatingThresholdsTitle,
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
                      color: RayyanColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: RayyanColors.primary.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const RayyanSymbol('info', color: RayyanColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.thresholdsInfoMessage,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? RayyanColors.slate300
                                      : RayyanColors.slate600,
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
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.thresholdsSavedSuccessfully,
                                ),
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
            label: AppLocalizations.of(context)!.fanLimitHighLabel,
            hint: AppLocalizations.of(context)!.fanLimitHighHint,
            controller: tempHighController,
            enabled: !isLoading,
            placeholder: ValueFormatter.nullPlaceholder,
          ),
          const SizedBox(height: 16),
          _ThresholdField(
            label: AppLocalizations.of(context)!.heaterLimitLowLabel,
            hint: AppLocalizations.of(context)!.heaterLimitLowHint,
            controller: tempLowController,
            enabled: !isLoading,
            placeholder: ValueFormatter.nullPlaceholder,
          ),
          const SizedBox(height: 16),
          _ThresholdField(
            label: AppLocalizations.of(context)!.phHighLimitLabel,
            hint: AppLocalizations.of(context)!.phHighLimitHint,
            controller: phHighController,
            enabled: !isLoading,
            placeholder: ValueFormatter.nullPlaceholder,
          ),
          const SizedBox(height: 16),
          _ThresholdField(
            label: AppLocalizations.of(context)!.phLowLimitLabel,
            hint: AppLocalizations.of(context)!.phLowLimitHint,
            controller: phLowController,
            enabled: !isLoading,
            placeholder: ValueFormatter.nullPlaceholder,
          ),
          const SizedBox(height: 16),
          _ThresholdField(
            label: AppLocalizations.of(context)!.ecHighLimitLabel,
            hint: AppLocalizations.of(context)!.ecHighLimitHint,
            controller: ecHighController,
            enabled: !isLoading,
            placeholder: ValueFormatter.nullPlaceholder,
          ),
          const SizedBox(height: 16),
          _ThresholdField(
            label: AppLocalizations.of(context)!.ecLowLimitLabel,
            hint: AppLocalizations.of(context)!.ecLowLimitHint,
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
                backgroundColor: RayyanColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isLoading
                    ? ValueFormatter.nullPlaceholder
                    : AppLocalizations.of(context)!.saveThresholds,
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
            color: isDark ? RayyanColors.slate400 : RayyanColors.slate500,
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
            fillColor: isDark
                ? RayyanColors.surfaceDark
                : RayyanColors.slate100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : RayyanColors.slate200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : RayyanColors.slate200,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key, required this.onNavigate});
  final ValueChanged<AppScreen> onNavigate;

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Initialize with default values (Critical Alerts ON by default)
  NotificationPreferences _prefs = const NotificationPreferences(
    pushEnabled: true,
    criticalAlertsEnabled: true, // ALWAYS ON DEFAULT (Requirement)
    parameterWarningsEnabled: true,
  );

  void _updatePrefs(NotificationPreferences newPrefs) {
    setState(() {
      _prefs = newPrefs;
    });
    // TODO: Connect to backend API or local storage here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          RayyanHeader(
            title: AppLocalizations.of(context)!.notificationSettingsTitle,
            onBack: () => widget.onNavigate(AppScreen.settings),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Master Toggle
                _buildSwitchTile(
                  title: AppLocalizations.of(context)!.pushNotifications,
                  subtitle: AppLocalizations.of(context)!.pushNotificationsSub,
                  value: _prefs.pushEnabled,
                  onChanged: (v) =>
                      _updatePrefs(_prefs.copyWith(pushEnabled: v)),
                ),
                const SizedBox(height: 24),

                // Section Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.alertsAndWarningsSection,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: RayyanColors.slate400,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Critical Alerts
                _buildSwitchTile(
                  title: AppLocalizations.of(context)!.criticalSystemFailures,
                  subtitle: AppLocalizations.of(
                    context,
                  )!.criticalSystemFailuresSub,
                  value: _prefs.criticalAlertsEnabled,
                  // If master toggle is off, these should visually look disabled or handle logic
                  // But for now, we just update the specific preference
                  onChanged: _prefs.pushEnabled
                      ? (v) => _updatePrefs(
                          _prefs.copyWith(criticalAlertsEnabled: v),
                        )
                      : null,
                ),

                const SizedBox(height: 8),

                // Water Level Alerts (NEW)
                _buildSwitchTile(
                  title: AppLocalizations.of(context)!.waterLevelAlerts,
                  subtitle: AppLocalizations.of(context)!.waterLevelAlertsSub,
                  value: _prefs.waterLevelNotificationsEnabled,
                  onChanged: _prefs.pushEnabled
                      ? (v) => _updatePrefs(
                          _prefs.copyWith(waterLevelNotificationsEnabled: v),
                        )
                      : null,
                ),

                const SizedBox(height: 8), // Spacing between tiles
                // Warnings
                _buildSwitchTile(
                  title: AppLocalizations.of(context)!.parameterWarnings,
                  subtitle: AppLocalizations.of(context)!.parameterWarningsSub,
                  value: _prefs.parameterWarningsEnabled,
                  onChanged: _prefs.pushEnabled
                      ? (v) => _updatePrefs(
                          _prefs.copyWith(parameterWarningsEnabled: v),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? RayyanColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : RayyanColors.slate200,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: RayyanColors.slate500),
        ),
        value: value,
        activeColor: RayyanColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onChanged: onChanged,
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
        color: isDark ? RayyanColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : RayyanColors.slate200,
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
            color: RayyanColors.slate500,
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
            fillColor: isDark
                ? RayyanColors.surfaceDark
                : RayyanColors.slate100,
            suffixIcon: suffixIcon,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: RayyanColors.critical,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: RayyanColors.critical,
                width: 1.2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : RayyanColors.slate200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : RayyanColors.slate200,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

