import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messenger/domain/repositories/i_auth_repository.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<String?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((User? user) => user?.uid);
  }

  @override
  Future<String> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<String> signUpWithEmail(
    String email,
    String password,
    String username,
  ) async {
    final cleanUsername = username.toLowerCase().trim();
    if (!(await isUsernameAvailable(cleanUsername))) {
      throw Exception('Username is taken');
    }

    final UserCredential userCredential;
    try {
      userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      await _firestore
          .collection('usernames')
          .doc(cleanUsername)
          .set({'used': true})
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception(
                'Firestore Timeout: Проверь правила безопасности базы (Rules) или настройки Эмулятора!',
              );
            },
          );
      await _firestore
          .collection('users')
          .doc(uid)
          .set({
            'uid': uid,
            'displayName': cleanUsername,
            'username': cleanUsername,
            'email': email,
            'photoUrl': '',
            'createdAt': FieldValue.serverTimestamp(),
          })
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Firestore Timeout при создании профиля юзера!');
            },
          );
      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on Exception catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Пользователь с такой почтой не найден.';
      case 'wrong-password':
        return 'Неверный пароль.';
      case 'email-already-in-use':
        return 'Эта почта уже занята другим аккаунтом.';
      case 'weak-password':
        return 'Пароль слишком слабый (минимум 6 символов).';
      default:
        return 'Произошла ошибка авторизации: ${e.message}';
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final cleanName = username.toLowerCase().trim();
    final doc = await _firestore.collection('usernames').doc(cleanName).get();

    return !doc.exists;
  }

  @override
  Future<void> updateUserOnlineStatus({
    required String userId,
    required bool isOnline,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(), 
      },);
    } catch (e) {
      log('Error updating online status: $e');
      rethrow; 
    }
  }
}
