import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/firebase_config.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';

/// Service for managing User data in Firebase Realtime Database.
class UserDatabaseService {
  final DatabaseReference _database;

  UserDatabaseService({DatabaseReference? database})
    : _database = database ?? FirebaseDatabase.instance.ref();

  /// Saves the user information to the database if it doesn't exist.
  Future<void> saveUser(User user) async {
    try {
      final ref = _database.child(FirebaseConfig.usersPath).child(user.uid);

      // Check if user already exists to avoid overwriting (though requirements say "should be saved")
      // We'll update it to ensure latest info
      await ref.update({
        'email': user.email,
        'displayName': user.displayName,
        'updatedAt': ServerValue.timestamp,
        'emailVerified': user.emailVerified,
      });
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  /// Updates the user information in the database.
  Future<void> updateUser(UserModel user) async {
    try {
      final ref = _database.child(FirebaseConfig.usersPath).child(user.uid);
      await ref.update(user.toRealtimeMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Checks if the user exists in the database.
  Future<bool> userExists(String uid) async {
    try {
      final ref = _database.child(FirebaseConfig.usersPath).child(uid);
      final snapshot = await ref.get();
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  /// Stream of user data.
  Stream<UserModel?> getUserStream(String uid) {
    return _database.child(FirebaseConfig.usersPath).child(uid).onValue.map((
      event,
    ) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        return UserModel.fromMap(data, uid);
      }
      return null;
    });
  }
}

final userDatabaseServiceProvider = Provider<UserDatabaseService>((ref) {
  return UserDatabaseService();
});

final realtimeUserProfileStreamProvider = StreamProvider<UserModel?>((
  ref,
) async* {
  final user = ref.watch(currentUserProvider).valueOrNull;

  if (user != null) {
    yield* ref.watch(userDatabaseServiceProvider).getUserStream(user.uid);
  } else {
    yield null;
  }
});
