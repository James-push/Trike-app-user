import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:user_application/appInfo/app_info.dart';
import 'package:user_application/authentication/login_screen.dart';
import 'package:user_application/pages/home_page.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  if(Platform.isAndroid)
  {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBl0OTiZegcNeX0wbNFmFXbUyoUtTLzGRo",
            authDomain: "trike-toda-application.firebaseapp.com",
            projectId: "trike-toda-application",
            storageBucket: "trike-toda-application.appspot.com",
            messagingSenderId: "654955706625",
            databaseURL: 'https://trike-toda-application-default-rtdb.asia-southeast1.firebasedatabase.app',
            appId: "1:654955706625:web:4cb1e2dd4dfdd09d4b4300",
            measurementId: "G-SN0HRBL5ZH"
        )
    );

  }
  else
  {
    await Firebase.initializeApp();
  }

  await Permission.locationWhenInUse.isDenied.then((value)
  {
    if(value)
    {
      Permission.locationWhenInUse.request();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'Users App',
        theme: ThemeData(
      
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false, // Remove the debug banner
        home: FirebaseAuth.instance.currentUser == null ? LoginScreen() : const HomePage(),
      ),
    );
  }
}


