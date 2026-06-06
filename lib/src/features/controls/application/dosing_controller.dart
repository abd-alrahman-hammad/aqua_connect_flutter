import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/firebase_config.dart';
import '../../../core/config/firebase_paths.dart';

class DosingState {
  final bool isEcUpActive;
  final bool isPhDownActive;
  final int ecUpSteps;
  final int phDownSteps;

  const DosingState({
    this.isEcUpActive = false,
    this.isPhDownActive = false,
    this.ecUpSteps = 0,
    this.phDownSteps = 0,
  });

  DosingState copyWith({
    bool? isEcUpActive,
    bool? isPhDownActive,
    int? ecUpSteps,
    int? phDownSteps,
  }) {
    return DosingState(
      isEcUpActive: isEcUpActive ?? this.isEcUpActive,
      isPhDownActive: isPhDownActive ?? this.isPhDownActive,
      ecUpSteps: ecUpSteps ?? this.ecUpSteps,
      phDownSteps: phDownSteps ?? this.phDownSteps,
    );
  }
}

class DosingController extends StateNotifier<DosingState> {
  final DatabaseReference _database;
  StreamSubscription? _sub;

  DosingController(this._database) : super(const DosingState()) {
    _startMonitoring();
  }

  void _startMonitoring() {
    final ref = _database.child(FirebasePaths.dosingControlPath);

    _sub = ref.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        final ecUpSteps = (data['ec_up_steps'] as num?)?.toInt() ?? 0;
        final phDownSteps = (data['ph_down_steps'] as num?)?.toInt() ?? 0;

        state = state.copyWith(
          ecUpSteps: ecUpSteps,
          phDownSteps: phDownSteps,
        );

        // Auto-refill logic: If the switch is ON and the hardware consumed the steps (back to 0), resend 400
        if (state.isEcUpActive && ecUpSteps == 0) {
          _sendEcUpSteps(400);
        }

        if (state.isPhDownActive && phDownSteps == 0) {
          _sendPhDownSteps(400);
        }
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> toggleEcUp(bool active) async {
    state = state.copyWith(isEcUpActive: active);
    if (active) {
      await _sendEcUpSteps(400);
    } else {
      await _sendEcUpSteps(0);
    }
  }

  Future<void> togglePhDown(bool active) async {
    state = state.copyWith(isPhDownActive: active);
    if (active) {
      await _sendPhDownSteps(400);
    } else {
      await _sendPhDownSteps(0);
    }
  }

  Future<void> _sendEcUpSteps(int steps) async {
    try {
      await _database.child(FirebasePaths.ecUpStepsPath).set(steps);
    } catch (e) {
      // Handle error quietly or log it
    }
  }

  Future<void> _sendPhDownSteps(int steps) async {
    try {
      await _database.child(FirebasePaths.phDownStepsPath).set(steps);
    } catch (e) {
      // Handle error quietly or log it
    }
  }
}

final dosingControllerProvider =
    StateNotifierProvider<DosingController, DosingState>((ref) {
  return DosingController(FirebaseConfig.getDatabaseReference());
});
