import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthFlowException implements Exception {
  const AuthFlowException(this.message);

  final String message;
}

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    return snapshot.data();
  }

  Future<Map<String, dynamic>?> waitForUserProfile(
    String uid, {
    int attempts = 6,
    Duration delay = const Duration(milliseconds: 400),
  }) async {
    for (int i = 0; i < attempts; i++) {
      final profile = await getUserProfile(uid);
      if (profile != null &&
          canonicalRole(profile['role'] as String?) != null) {
        return profile;
      }
      await Future<void>.delayed(delay);
    }
    return null;
  }

  String? canonicalRole(String? role) {
    switch (role) {
      case 'admin':
      case 'Admin':
        return 'admin';
      case 'board':
      case 'Board':
      case 'Board Member':
        return 'board';
      case 'staff':
      case 'Staff':
        return 'staff';
      case 'viewer':
      case 'Viewer':
        return 'viewer';
      default:
        return null;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw const AuthFlowException('Unable to create your account right now.');
    }

    await user.updateDisplayName(fullName);

    final canonical = canonicalRole(role);
    if (canonical == null) {
      throw const AuthFlowException('Please choose a valid role.');
    }

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': fullName,
        'email': email,
        'role': canonical,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Sign-up profile save failed: $error');
      }
      await user.delete();
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _auth.signOut();
}
