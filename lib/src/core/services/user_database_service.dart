import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/firebase_config.dart';

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
}

final userDatabaseServiceProvider = Provider<UserDatabaseService>((ref) {
  return UserDatabaseService();
});
