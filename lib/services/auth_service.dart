import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user?.uid;
    if (uid == null) {
      throw const AuthFlowException('Unable to sign in right now.');
    }

    final profile = await _firestore.collection('users').doc(uid).get();
    if (!profile.exists) {
      await _auth.signOut();
      throw const AuthFlowException(
        'Your account exists, but your profile is missing. Please contact support.',
      );
    }

    final role = canonicalRole(profile.data()?['role'] as String?);
    if (role == null) {
      await _auth.signOut();
      throw const AuthFlowException(
        'Your account role is not valid yet. Please contact an administrator.',
      );
    }
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

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _auth.signOut();
}
