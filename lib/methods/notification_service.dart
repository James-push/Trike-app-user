import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For decoding payload

// GlobalKey for navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    _initialize();
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize notification settings
  void _initialize() {
    var androidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: androidSettings);

    // Set up notification initialization
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
          _onSelectNotification(notificationResponse);
        });

    _firebaseMessaging.requestPermission();

    /*
    // Foreground notification handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground notification received: ${message.notification?.title}");
      _showNotification(message);
    });
     */

    // Background/terminated notification tap handling
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification tapped in background/terminated:");

      // Extract data from the notification
      String? title = message.notification?.title;
      String? body = message.notification?.body;
      Map<String, dynamic> data = message.data;

      // Show the notification content in a dialog
      _showNotificationContent(navigatorKey.currentContext!, title, body, data);
    });

    // Background handler for when the app is terminated
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  // Show notification content when the app is tapped
  void _showNotificationContent(BuildContext context, String? title, String? body, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? 'No Title'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Body: $body'),
              SizedBox(height: 10),
              Text('Data: ${data.toString()}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show local notification when app is in the foreground
  Future<void> _showNotification(RemoteMessage message) async {
    var androidDetails = const AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    // Show the notification
    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: json.encode(message.data), // Send payload for tap handling
    );
  }

  // Handle notification tap when app is in the foreground or background
  void _onSelectNotification(NotificationResponse notificationResponse) {
    print("Notification tapped! Payload: ${notificationResponse.payload}");

    if (notificationResponse.payload != null) {
      // Parse the payload
      Map<String, dynamic> data = Map<String, dynamic>.from(json.decode(notificationResponse.payload!));
      _handleNotificationClick(data);
    }
  }

  // Handle navigation based on payload data
  void _handleNotificationClick(Map<String, dynamic> data) {
    String? page = data['page'];
    print("Notification payload received, navigating to page: $page");

    if (navigatorKey.currentState != null) {
      // Navigate to the appropriate page based on the payload
      if (page == 'login') {
        // Show the dialog with the notification details
        _showDialog(data['title'], data['body']);

        // Navigate to the Login screen
        navigatorKey.currentState?.pushReplacementNamed('/login');
      } else if (page == 'pending driver') {
        // Navigate to Pending Drivers Page
        navigatorKey.currentState?.pushReplacementNamed('/pending_drivers');
      } else {
        // Default: Navigate to Home Page
        navigatorKey.currentState?.pushReplacementNamed('/home');
      }
    } else {
      print('Navigator Key is unavailable');
    }
  }

  void _showDialog(String? title, String? body) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification Received'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Title: $title'),
              SizedBox(height: 8),
              Text('Body: $body'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Optional: Background handler for when the app is terminated
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print('Handling background message: ${message.notification?.title}');
    // Handle background message logic here
  }
}