import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Custom exception for database errors
class DatabaseException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const DatabaseException(this.message, [this.code, this.originalError]);

  @override
  String toString() =>
      'DatabaseException: $message${code != null ? ' ($code)' : ''}';
}

/// Stream provider for connection status
/// Returns true if connected to Firebase, false otherwise.
final connectionStatusStreamProvider = StreamProvider<bool>((ref) {
  return FirebaseDatabase.instance.ref('.info/connected').onValue.map((event) {
    return (event.snapshot.value as bool?) ?? false;
  });
});
