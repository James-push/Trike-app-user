import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';


class UserService {
  UserService._privateConstructor();
  static final UserService instance = UserService._privateConstructor();

  // Fetch the current user ID from Firebase Authentication
  Future<String?> getCurrentUserId() async {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login'); // Navigate to the LoginScreen
    } catch (e) {
      print("Error signing out: $e");
      // Optionally show an error message
    }
  }
}
