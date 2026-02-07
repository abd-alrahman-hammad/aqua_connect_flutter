import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, [this.code]);

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' ($code)' : ''}';
}

/// Service for handling Firebase Authentication operations.
///
/// This service provides authentication functionality for the Rayyan
/// hydroponic system, including test user login and auth state management.
///
/// Usage with Riverpod:
/// ```dart
/// final authService = ref.watch(firebaseAuthServiceProvider);
/// await authService.signInWithTestCredentials();
/// ```
class FirebaseAuthService {
  final FirebaseAuth _auth;

  /// Creates a new [FirebaseAuthService] instance
  ///
  /// [auth] - Optional FirebaseAuth instance for testing/dependency injection
  FirebaseAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  // ============================================================================
  // Test User Credentials (as specified in requirements)
  // ============================================================================

  /// Test user email from the credentials image
  static const String testEmail = 'test@test.com';

  /// Test user password from the credentials image
  static const String testPassword = '123456';

  // ============================================================================
  // Authentication Methods
  // ============================================================================

  /// Signs in using the test credentials (test@test.com / 123456)
  ///
  /// This method authenticates the user with Firebase Auth using the
  /// hardcoded test credentials provided in the system requirements.
  ///
  /// Returns the authenticated [User] object on success.
  ///
  /// Throws [AuthException] if authentication fails with details about:
  /// - Invalid credentials
  /// - Network errors
  /// - Disabled user account
  /// - Other Firebase Auth errors
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final user = await authService.signInWithTestCredentials();
  ///   print('Logged in as: ${user.email}');
  /// } catch (e) {
  ///   print('Login failed: $e');
  /// }
  /// ```
  Future<User> signInWithTestCredentials() async {
    try {
      // Attempt to sign in with email and password
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      // Check if user object exists
      if (userCredential.user == null) {
        throw const AuthException(
          'Sign in succeeded but user object is null',
          'null-user',
        );
      }

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'user-not-found':
          throw const AuthException(
            'No user found with email: $testEmail. '
                'Please create the user in Firebase Console.',
            'user-not-found',
          );
        case 'wrong-password':
          throw const AuthException(
            'Invalid password for test user',
            'wrong-password',
          );
        case 'user-disabled':
          throw const AuthException(
            'Test user account has been disabled',
            'user-disabled',
          );
        case 'invalid-email':
          throw const AuthException(
            'Invalid email format: $testEmail',
            'invalid-email',
          );
        case 'network-request-failed':
          throw const AuthException(
            'Network error: Please check your internet connection',
            'network-request-failed',
          );
        default:
          throw AuthException('Authentication failed: ${e.message}', e.code);
      }
    } catch (e) {
      // Handle unexpected errors
      throw AuthException('Unexpected error during authentication: $e');
    }
  }

  /// Signs in with custom email and password
  ///
  /// This method allows authentication with any email/password combination.
  /// Caller must check [User.emailVerified] before granting access.
  ///
  /// Throws [AuthException] on failure.
  Future<User> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const AuthException('User object is null after sign in');
      }

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapSignInError(e.code), e.code);
    } catch (e) {
      throw AuthException('Unexpected error: $e');
    }
  }

  /// Maps Firebase Auth error codes to user-friendly messages.
  static String _mapSignInError(String code) {
    switch (code) {
      case 'wrong-password':
        return 'Wrong password';
      case 'user-not-found':
        return 'No account found for this email';
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Login failed. Please try again';
    }
  }

  /// Sends an email verification link to the given user.
  Future<void> sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        'Failed to send verification email: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw AuthException('Failed to send verification email: $e');
    }
  }

  /// Creates a new user account with email and password
  ///
  /// Throws [AuthException] on failure (e.g., email already in use).
  Future<User> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const AuthException('User object is null after creation');
      }

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered';
        case 'invalid-email':
          message = 'Invalid email format';
        case 'weak-password':
          message = 'Password must be at least 8 characters';
        default:
          message = 'Registration failed. Please try again';
      }
      throw AuthException(message, e.code);
    } catch (e) {
      throw AuthException('Unexpected error during registration: $e');
    }
  }

  /// Sends a password reset email to the specified address
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found for this email';
        case 'invalid-email':
          message = 'Invalid email format';
        default:
          message = 'Failed to send reset email. Please try again';
      }
      throw AuthException(message, e.code);
    } catch (e) {
      throw AuthException('Unexpected error: $e');
    }
  }

  /// Re-authenticates the current user with email and password
  ///
  /// Required for sensitive operations like changing password.
  Future<void> reauthenticateUser(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('No user currently signed in');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Wrong password';
        default:
          message = 'Re-authentication failed. Please try again';
      }
      throw AuthException(message, e.code);
    } catch (e) {
      throw AuthException('Unexpected error: $e');
    }
  }

  /// Updates the user's password
  ///
  /// [reauthenticateUser] should usually be called before this.
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('No user currently signed in');
    }

    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password must be at least 8 characters';
        case 'requires-recent-login':
          message =
              'Security verification required. Please sign out and sign in again.';
        default:
          message = 'Failed to update password. Please try again';
      }
      throw AuthException(message, e.code);
    } catch (e) {
      throw AuthException('Unexpected error: $e');
    }
  }

  /// Updates the user's display name
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('No user currently signed in');
    }

    try {
      await user.updateDisplayName(name);
      await user.reload();
    } catch (e) {
      throw AuthException('Failed to update profile name: $e');
    }
  }

  /// Signs out the current user
  ///
  /// Example:
  /// ```dart
  /// await authService.signOut();
  /// ```
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  /// Gets the currently authenticated user (if any)
  ///
  /// Returns `null` if no user is signed in.
  User? get currentUser => _auth.currentUser;

  /// Returns true if a user is currently authenticated
  bool get isAuthenticated => currentUser != null;

  /// Stream of authentication state changes
  ///
  /// Emits:
  /// - [User] object when user signs in
  /// - `null` when user signs out
  ///
  /// Example:
  /// ```dart
  /// authService.authStateChanges.listen((user) {
  ///   if (user != null) {
  ///     print('User signed in: ${user.email}');
  ///   } else {
  ///     print('User signed out');
  ///   }
  /// });
  /// ```
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Stream of user changes (includes token refresh)
  ///
  /// This stream also emits events when the user's token is refreshed,
  /// which is useful for ensuring database access permissions are up to date.
  Stream<User?> get userChanges => _auth.userChanges();

  /// Reloads the current user's data from Firebase
  ///
  /// Useful for getting the latest user information after profile updates.
  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
    } catch (e) {
      throw AuthException('Failed to reload user: $e');
    }
  }

  /// Gets the current user's ID token
  ///
  /// This token is used for authenticating requests to Firebase services.
  /// Returns `null` if no user is signed in.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      return await currentUser?.getIdToken(forceRefresh);
    } catch (e) {
      throw AuthException('Failed to get ID token: $e');
    }
  }
}

// ============================================================================
// Riverpod Providers
// ============================================================================

/// Provider for [FirebaseAuthService]
///
/// Usage:
/// ```dart
/// final authService = ref.watch(firebaseAuthServiceProvider);
/// ```
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

/// Provider for current user stream
///
/// Usage:
/// ```dart
/// final userAsync = ref.watch(currentUserProvider);
/// userAsync.when(
///   data: (user) => Text(user?.email ?? 'Not signed in'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, st) => Text('Error: $e'),
/// );
/// ```
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

/// Provider for checking if user is authenticated
///
/// Usage:
/// ```dart
/// final isAuth = ref.watch(isAuthenticatedProvider);
/// if (isAuth) {
///   // Show authenticated content
/// }
/// ```
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.value != null;
});
