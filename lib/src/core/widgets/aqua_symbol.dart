import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AquaSymbol extends StatelessWidget {
  const AquaSymbol(
    this.name, {
    super.key,
    this.size,
    this.color,
    this.fill = 1,
    this.weight = 400,
  });

  final String name;
  final double? size;
  final Color? color;
  final double fill; // 0..1
  final double weight; // 100..700

  IconData get _icon {
    switch (name) {
      case 'grid_view':
        return Symbols.grid_view_rounded;
      case 'settings_input_component':
        return Symbols.settings_input_component_rounded;
      case 'filter_center_focus':
        return Symbols.filter_center_focus_rounded;
      case 'apps':
        return Symbols.apps_rounded;
      case 'settings':
        return Symbols.settings_rounded;
      case 'arrow_back_ios_new':
        return Symbols.arrow_back_ios_new_rounded;
      case 'arrow_back':
        return Symbols.arrow_back_rounded;
      case 'notifications':
        return Symbols.notifications_rounded;
      case 'water_drop':
        return Symbols.water_drop_rounded;
      case 'water_ph':
        return Symbols.water_ph_rounded;
      case 'bolt':
        return Symbols.bolt_rounded;
      case 'device_thermostat':
        return Symbols.device_thermostat_rounded;
      case 'humidity_percentage':
        return Symbols.humidity_percentage_rounded;
      case 'waves':
        return Symbols.waves_rounded;
      case 'analytics':
        return Symbols.analytics_rounded;
      case 'sync':
        return Symbols.sync_rounded;
      case 'sync_alt':
        return Symbols.sync_alt_rounded;
      case 'sensors':
        return Symbols.sensors_rounded;
      case 'monitoring':
        return Symbols.monitoring_rounded;
      case 'psychology':
        return Symbols.psychology_rounded;
      case 'speed':
        return Symbols.speed_rounded;
      case 'help':
        return Symbols.help_rounded;
      case 'person':
        return Symbols.person_rounded;
      case 'wifi':
        return Symbols.wifi_rounded;
      case 'wifi_lock':
        return Symbols.wifi_lock_rounded;
      case 'signal_wifi_4_bar':
        return Symbols.signal_wifi_4_bar_rounded;
      case 'close':
        return Symbols.close_rounded;
      case 'add_circle':
        return Symbols.add_circle_rounded;
      case 'memory':
        return Symbols.memory_rounded;
      case 'edit':
        return Symbols.edit_rounded;
      case 'refresh':
        return Symbols.refresh_rounded;
      case 'cloud_off':
        return Symbols.cloud_off_rounded;
      case 'verified':
        return Symbols.verified_rounded;
      case 'logout':
        return Symbols.logout_rounded;
      case 'dark_mode':
        return Symbols.dark_mode_rounded;
      case 'language':
        return Symbols.language_rounded;
      case 'lock':
        return Symbols.lock_rounded;
      case 'precision_manufacturing':
        return Symbols.precision_manufacturing_rounded;
      case 'update':
        return Symbols.update_rounded;
      case 'chevron_right':
        return Symbols.chevron_right_rounded;
      case 'done_all':
        return Symbols.done_all_rounded;
      case 'warning':
        return Symbols.warning_rounded;
      case 'eco':
        return Symbols.eco_rounded;
      case 'light_mode':
        return Symbols.light_mode_rounded;
      case 'history_edu':
        return Symbols.history_edu_rounded;
      case 'search':
        return Symbols.search_rounded;
      case 'play_arrow':
        return Symbols.play_arrow_rounded;
      case 'smart_toy':
        return Symbols.smart_toy_rounded;
      case 'ios_share':
        return Symbols.ios_share_rounded;
      case 'trending_down':
        return Symbols.trending_down_rounded;
      case 'trending_up':
        return Symbols.trending_up_rounded;
      case 'lightbulb':
        return Symbols.lightbulb_rounded;
      case 'check_circle':
        return Symbols.check_circle_rounded;
      case 'info':
        return Symbols.info_rounded;
      case 'arrow_forward':
        return Symbols.arrow_forward_rounded;
      case 'mode_fan':
        return Symbols.mode_fan_rounded;
      case 'science':
        return Symbols.science_rounded;
      case 'opacity':
        return Symbols.opacity_rounded;
      case 'keyboard_arrow_up':
        return Symbols.keyboard_arrow_up_rounded;
      case 'keyboard_arrow_down':
        return Symbols.keyboard_arrow_down_rounded;
      case 'flare':
        return Symbols.flare_rounded;
      case 'thermostat':
        return Symbols.thermostat_rounded;
      case 'system_update':
        return Symbols.system_update_rounded;
      case 'check':
        return Symbols.check_rounded;
      case 'expand_more':
        return Symbols.expand_more_rounded;
      case 'remove':
        return Symbols.remove_rounded;
      case 'add':
        return Symbols.add_rounded;
      case 'visibility':
        return Symbols.visibility_rounded;
      case 'visibility_off':
        return Symbols.visibility_off_rounded;
      case 'face':
        return Symbols.face_rounded;
      default:
        return Symbols.help_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _icon,
      size: size,
      color: color,
      fill: fill,
      weight: weight,
      opticalSize: 24,
      grade: 0,
    );
  }
}
