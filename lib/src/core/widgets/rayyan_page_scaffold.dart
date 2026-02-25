import 'package:flutter/material.dart';

import '../../app/screens.dart';
import 'rayyan_bottom_nav.dart';

class RayyanPageScaffold extends StatelessWidget {
  const RayyanPageScaffold({
    super.key,
    required this.currentScreen,
    required this.onNavigate,
    required this.child,
    this.backgroundColor,
    this.includeBottomNav = true,
    this.scrollable = true,
  });

  final AppScreen currentScreen;
  final ValueChanged<AppScreen> onNavigate;
  final Widget child;
  final Color? backgroundColor;
  final bool includeBottomNav;
  final bool scrollable;

  static const double _dockOverlapSpacer = 112; // matches web `h-28`

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        scrollable ? child : Expanded(child: child),
        if (includeBottomNav) const SizedBox(height: _dockOverlapSpacer),
      ],
    );

    if (scrollable) {
      content = SingleChildScrollView(child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(top: false, bottom: false, child: content),
          if (includeBottomNav)
            RayyanBottomNav(current: currentScreen, onNavigate: onNavigate),
        ],
      ),
    );
  }
}
