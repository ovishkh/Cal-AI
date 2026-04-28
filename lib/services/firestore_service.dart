import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save or update user profile
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Firestore Save User Exception: $e');
      }
      rethrow;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      if (kDebugMode) {
        print('Firestore Get User Exception: $e');
      }
      rethrow;
    }
  }

  // Save generated recipe
  Future<void> saveRecipe({
    required String uid,
    required Recipe recipe,
  }) async {
    try {
      await _db.collection('users').doc(uid).collection('recipes').add({
        ...recipe.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Firestore Save Recipe Exception: $e');
      }
      rethrow;
    }
  }

  // Stream of recipes for a user
  Stream<List<Recipe>> getRecipesStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Recipe.fromJson(data);
          }).toList();
        });
  }
}
