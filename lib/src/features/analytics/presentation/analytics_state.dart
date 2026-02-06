import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to store the initial tab for the Analytics Screen.
/// Used when navigating from Dashboard to a specific sensor chart.
final analyticsTabProvider = StateProvider<String?>((ref) => null);
