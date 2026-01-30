import 'package:flutter/material.dart';

import '../../app/screens.dart';
import 'aqua_bottom_nav.dart';

class AquaPageScaffold extends StatelessWidget {
  const AquaPageScaffold({
    super.key,
    required this.currentScreen,
    required this.onNavigate,
    required this.child,
    this.backgroundColor,
    this.includeBottomNav = true,
  });

  final AppScreen currentScreen;
  final ValueChanged<AppScreen> onNavigate;
  final Widget child;
  final Color? backgroundColor;
  final bool includeBottomNav;

  static const double _dockOverlapSpacer = 112; // matches web `h-28`

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  child,
                  if (includeBottomNav)
                    const SizedBox(height: _dockOverlapSpacer),
                ],
              ),
            ),
          ),
          if (includeBottomNav)
            AquaBottomNav(current: currentScreen, onNavigate: onNavigate),
        ],
      ),
    );
  }
}
