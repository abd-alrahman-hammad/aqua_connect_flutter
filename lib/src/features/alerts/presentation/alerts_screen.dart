import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../app/screens.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/widgets/aqua_header.dart';
import '../../../core/widgets/aqua_page_scaffold.dart';
import '../../../core/widgets/aqua_symbol.dart';
import '../application/sensor_monitor_service.dart';
import '../domain/alert_model.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the sensor monitor service to ensure it starts watching
    // We do this in initState (or could be done in main.dart) to ensure it's active
    // when this screen is opened.
    // However, for the simulation to work globally, this should ideally be watched
    // at a higher level (like in the main App widget).
    // For now, we assume the user visits this screen to see alerts.
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the service is alive and watching
    ref.watch(sensorMonitorServiceProvider);

    final alerts = ref.watch(alertsProvider);

    return AquaPageScaffold(
      currentScreen: widget.current,
      onNavigate: widget.onNavigate,
      includeBottomNav: false,
      child: Column(
        children: [
          AquaHeader(
            title: AppLocalizations.of(context)!.alertsAndNotificationsTitle,
            onBack: () => widget.onNavigate(AppScreen.dashboard),
            rightAction: IconButton(
              onPressed: () {
                ref.read(alertsProvider.notifier).clearAll();
              },
              icon: const AquaSymbol('done_all'),
            ),
          ),

          alerts.isEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: _buildEmptyState(context),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return _buildAlertItem(context, ref, alert);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(
    BuildContext context,
    WidgetRef ref,
    AlertModel alert,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(alert.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: AquaColors.critical,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline, color: Colors.white),
              SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.dismiss,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
        onDismissed: (direction) {
          ref.read(alertsProvider.notifier).removeAlert(alert.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.alertDismissed(alert.title),
              ),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: AppLocalizations.of(context)!.undo,
                onPressed: () {
                  ref.read(alertsProvider.notifier).addAlert(alert);
                },
              ),
            ),
          );
        },
        child: _AlertCard(alert: alert),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AquaColors.nature.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const AquaSymbol(
              'check_circle',
              size: 48,
              color: AquaColors.nature,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.allSystemsNominal,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AquaColors.nature,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.noActiveAlerts,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AquaColors.slate400),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final AlertModel alert;

  @override
  Widget build(BuildContext context) {
    Color border = AquaColors.info;
    Color iconColor = AquaColors.info;
    Color iconBg = AquaColors.info.withValues(alpha: 0.10);

    if (alert.type == AlertType.critical) {
      border = AquaColors.critical;
      iconColor = AquaColors.critical;
      iconBg = AquaColors.critical.withValues(alpha: 0.10);
    } else if (alert.type == AlertType.warning) {
      border = AquaColors.warning;
      iconColor = AquaColors.warning;
      iconBg = AquaColors.warning.withValues(alpha: 0.10);
    } else if (alert.type == AlertType.optimal) {
      border = AquaColors.nature;
      iconColor = AquaColors.nature;
      iconBg = AquaColors.nature.withValues(alpha: 0.10);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AquaColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: border, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: AquaSymbol(alert.icon, color: iconColor, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(alert.timestamp),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AquaColors.slate400
                              : AquaColors.slate500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    alert.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? AquaColors.slate300 : AquaColors.slate600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
