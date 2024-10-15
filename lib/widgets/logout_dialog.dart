import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../authentication/login_screen.dart';

class LogoutDialog {
  static void showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text("Yes"),
            onPressed: () async {
              // Sign out from Firebase
              await FirebaseAuth.instance.signOut();

              // This will clear the entire navigation stack and replace it with the login screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (c) => const LoginScreen()),
                    (Route<dynamic> route) => false, // Remove all routes
              );
            },
          ),
        ],
      ),
    );
  }
}
