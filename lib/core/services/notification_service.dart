import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("background push: ${message.notification?.title}");
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize(String currentUserId) async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('got access to push noifications!');

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      _initForegroundMessaging();
      await _saveDeviceToken(currentUserId);

      _messaging.onTokenRefresh.listen((newToken) async {
        await _updateTokenInFirestore(currentUserId, newToken);
      });
    } else {
      log('User didnt allow push notifs');
    }
  }

  Future<void> _saveDeviceToken(String userId) async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _updateTokenInFirestore(userId, token);
      }
    } catch (e) {
      log("error getting FCM token: $e");
    }
  }

  Future<void> _updateTokenInFirestore(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
      log("FCM token updated for user: $userId");
    } catch (e) {
      log(
        "cant update firestore token: $e",
      );
    }
  }

  void _initForegroundMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log(
        "push in opened app: ${message.notification?.title} -> ${message.notification?.body}",
      );
      // TODO
    });
  }

  /// can call this even if the user is not logged in and pass null userId
  Future<void> removeToken(String? userId) async {
    if (userId == null) {
      return;
    } else {
      try {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': FieldValue.delete(),
        });
        await _messaging.deleteToken();
        log("FCM token deleted");
      } catch (e) {
        log("error deleting token: $e");
      }
    }
  }
}
