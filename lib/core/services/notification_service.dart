import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:messenger/presentation/settings/bloc/settings_bloc.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("background push: ${message.notification?.title}");
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  SettingsBloc? _settingsBloc;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize(String currentUserId, SettingsBloc settingsBloc) async {
    _settingsBloc = settingsBloc;
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('got access to push noifications!');

      await _initLocalNotifications();

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      _initForegroundMessaging();
      await _saveDeviceToken(currentUserId);

      _messaging.onTokenRefresh.listen((newToken) async {
        await _updateTokenInFirestore(currentUserId, newToken);
      });

      // fully closed
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      _onNotificationClick(initialMessage?.data);

      // app open in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _onNotificationClick(message.data);
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
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        _showLocalNotification(notification, android, message.data);
      }
    });
  }

  void _showLocalNotification(
    RemoteNotification notification, 
    AndroidNotification? android, 
    Map<String, dynamic> data,
  ) {
    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'message_channel',
          'Messages',       
          importance: Importance.max,
          priority: Priority.high,
          icon: android?.smallIcon,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
      payload: jsonEncode(data), 
    );
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
  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher'); 

    const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: false, 
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log("clicked local push in foreground: ${response.payload}");
        final pl = response.payload;
        _onNotificationClick((pl != null) ? (jsonDecode(pl)) : null);
      },
    );
  }

  Future<void> _onNotificationClick(Map<String, dynamic>? payload) {
    if (payload == null) return Future.value(); 
    log('here im supposed to open chat $payload');
    _settingsBloc!.add(SettingsPushScreen(data: payload));
    return Future.value(); // TODO
  }
}

