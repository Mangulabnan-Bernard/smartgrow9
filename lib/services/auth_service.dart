import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _isInitialized = false;

  // Initialize Firebase
  static Future<void> initialize() async {
    if (!_isInitialized) {
      await Firebase.initializeApp();
      _isInitialized = true;
    }
  }

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time in Firestore
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'lastLoginAt': DateTime.now().toIso8601String()});
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get user profile from Firestore with retry logic
  static Future<UserProfile?> getUserProfile(String userId) async {
    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (doc.exists) {
          return UserProfile.fromJson(doc.data()!);
        }
        return null;
      } catch (e) {
        print('Attempt $attempt: Error getting user profile: $e');

        // If this is the last attempt, return null
        if (attempt == maxRetries) {
          print('All retry attempts failed for user profile loading');
          return null;
        }

        // Wait before retrying
        await Future.delayed(retryDelay);
      }
    }

    return null;
  }

  // Update user profile
  static Future<void> updateUserProfile(String userId, UserProfile profile) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(profile.toJson());
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  // Create account with email and password
  static Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      if (userCredential.user != null) {
        final userProfile = UserProfile(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userProfile.toJson());
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  static Future<void> signOut() async {
    print('AuthService Debug: Signing out user...');
    await _auth.signOut();
    print('AuthService Debug: User signed out successfully');
  }

  // Handle Firebase Auth errors
  static Exception _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'invalid-user-token':
        case 'user-token-expired':
          return Exception('Email or password is incorrect.');
        case 'wrong-password':
        case 'invalid-password':
          return Exception('Email or password is incorrect.');
        case 'invalid-credential':
        case 'invalid-email':
          return Exception('Email or password is incorrect.');
        case 'email-already-in-use':
          return Exception('An account already exists with this email.');
        case 'weak-password':
          return Exception('Password is too weak.');
        case 'user-disabled':
          return Exception('This user account has been disabled.');
        case 'too-many-requests':
          return Exception('Too many failed attempts. Please try again later.');
        case 'operation-not-allowed':
          return Exception('This sign-in method is not enabled.');
        case 'network-request-failed':
        case 'timeout':
        case 'unavailable':
          return Exception('No internet connection. Please check your network and try again.');
        default:
          // Check if the error message contains credential-related keywords
          String message = error.message?.toLowerCase() ?? '';
          if (message.contains('credential') || message.contains('auth') || message.contains('sign')) {
            return Exception('Email or password is incorrect.');
          }
          // Check if the error message contains network-related keywords
          if (message.contains('network') || message.contains('timeout') || message.contains('connection')) {
            return Exception('No internet connection. Please check your network and try again.');
          }
          return Exception('Authentication failed. Please try again.');
      }
    }
    return Exception('An unexpected error occurred. Please try again.');
  }
}
