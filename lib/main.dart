import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AquaConnectApp()));
}

/// Lightweight harness to use in widget tests.
class TestAppHarness extends StatelessWidget {
  const TestAppHarness({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: AquaConnectApp());
  }
}
