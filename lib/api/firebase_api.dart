import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';

import 'package:http/http.dart' as http;

Future<void> handleBackgroundMessage(RemoteMessage message)async{

}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notification',
    importance: Importance.defaultImportance,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {

    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');
    initPushNotifications();
    initLocalNotifications();
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    // navigatorKey.currentState?.pushNamed(
    //   '/chat_screen',
    //   arguments: message,
    // );
    navigatorKey.currentState?.pushNamed(
      '/notify_screen',
      arguments: message,
    );
  }

  Future initLocalNotifications()async{
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(
      settings, onDidReceiveNotificationResponse: (response){
        final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
        handleMessage(message);
    }
    );
    final platform = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((handleMessage));
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@drawable/ic_launcher',
            ),
          ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  Future<void> sendNotification(
      String deviceToken, String title, String body, Map<String, dynamic> customData) async {
    final data = {
      'notification': {'title': title, 'body': body},
      'priority': 'high',
      'data': customData,
      'to': deviceToken,
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAHMGBr5I:APA91bGHszuDs2rteSlJjbVw9e_3GRxjtGN3-Sd98sUTMRY2JhCIOacQmlWuWdv4s_z0obrX9LG0vLJXL74g6avgR2iX7JLfBw_Piy-NVgfRrKb8QS_9NLxvNIBtU57vlG6lV9nYxrks',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('Thông báo đã được gửi thành công');
    } else {
      print('Lỗi khi gửi thông báo: ${response.reasonPhrase}');
    }
  }
  Future<void> sendNotificationAdmin(
      List<String> deviceToken, String title, String body) async {
    final data = {
      'notification': {'title': title, 'body': body},
      'priority': 'high',
      'registration_ids': deviceToken,
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
        'key=AAAAHMGBr5I:APA91bGHszuDs2rteSlJjbVw9e_3GRxjtGN3-Sd98sUTMRY2JhCIOacQmlWuWdv4s_z0obrX9LG0vLJXL74g6avgR2iX7JLfBw_Piy-NVgfRrKb8QS_9NLxvNIBtU57vlG6lV9nYxrks',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('Thông báo đã được gửi thành công');
    } else {
      print('Lỗi khi gửi thông báo:  ${response.statusCode}, ${response.body}');
    }
  }
}
