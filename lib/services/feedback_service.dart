import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FeedbackService {
  FeedbackService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> saveFeedback({
    required String userId,
    required String feedbackText,
  }) async {
    try {
      await _firestore.collection('usapho_feedback').add({
        'userId': userId,
        'feedbackText': feedbackText,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (kDebugMode) {
        debugPrint('Saved feedback for user: $userId');
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to save feedback: $error');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }
}
