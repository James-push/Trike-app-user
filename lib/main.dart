import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:user_application/appInfo/app_info.dart';
import 'package:user_application/authentication/login_screen.dart';
import 'package:user_application/pages/order_tracking_state_page.dart';
import 'package:user_application/widgets/main_screen.dart';

import 'methods/notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and handle potential errors
  await _initializeFirebase();

  // Check and request location permissions
  await _checkAndRequestLocationPermission();

  // Run the app
  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    if (Platform.isAndroid) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBl0OTiZegcNeX0wbNFmFXbUyoUtTLzGRo",
          authDomain: "trike-toda-application.firebaseapp.com",
          projectId: "trike-toda-application",
          storageBucket: "trike-toda-application.appspot.com",
          messagingSenderId: "654955706625",
          databaseURL: 'https://trike-toda-application-default-rtdb.asia-southeast1.firebasedatabase.app',
          appId: "1:654955706625:web:4cb1e2dd4dfdd09d4b4300",
          measurementId: "G-SN0HRBL5ZH",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
}

Future<void> _checkAndRequestLocationPermission() async {
  PermissionStatus status = await Permission.locationWhenInUse.status;

  if (status.isDenied || status.isRestricted) {
    status = await Permission.locationWhenInUse.request();
  }

  if (status.isPermanentlyDenied) {
    // Open the app settings to manually allow location permission
    await openAppSettings();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    NotificationService();
    _submitTokenToDatabase(context);
  }

  Future<void> _submitTokenToDatabase(BuildContext context) async {
    try {
      await messaging.requestPermission();

      String? token = await messaging.getToken();

      FirebaseAuth auth = FirebaseAuth.instance;
      User? firebaseUser = auth.currentUser;

      if (firebaseUser != null) {
        // Storing token in Firebase Realtime Database
        Map<String, String> tokenDataMap = {
          "token": token!,
        };

        await FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(firebaseUser.uid)
            .update(tokenDataMap);

        print("Token: $token updated");
      }
    } catch (e) {
      print("Error during token submission: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'Users App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffefefef)),
          useMaterial3: true,
          fontFamily: 'Roboto', // Set default font family
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: FirebaseAuth.instance.currentUser == null
            ? '/login'
            : '/home',
        routes: {
          '/home': (context) => MainScreen(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}
