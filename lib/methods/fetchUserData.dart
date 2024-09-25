import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'user_service.dart';

class fetchUserData{
  static Future<String> fetchUserName() async {
    final userId = await UserService.instance.getCurrentUserId();
    if (userId == null) {
      return 'Unknown User';
    }

    final DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$userId');
    final DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;
      return userData['name'] ?? 'Unknown User';
    } else {
      return 'Unknown User';
    }
  }

  static Future<String> fetchUserEmail() async {
    final userId = await UserService.instance.getCurrentUserId();
    if (userId == null) {
      return 'Unknown User';
    }

    final DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$userId');
    final DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;
      return userData['email'] ?? 'Unknown User';
    } else {
      return 'Unknown User';
    }
  }

  static Future<String> fetchUserNumber() async {
    final userId = await UserService.instance.getCurrentUserId();
    if (userId == null) {
      return 'Unknown User';
    }

    final DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$userId');
    final DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;
      return userData['phone'] ?? 'Unknown User';
    } else {
      return 'Unknown User';
    }
  }

  static Future<String> fetchUserProfilePicture() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the currently authenticated user

    if (user != null) {
      // Reference to the user's data in the Firebase Realtime Database
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid);

      // Fetch the profile picture URL from the user's data
      DataSnapshot snapshot = await userRef.child('profileUrl').get();

      if (snapshot.exists) {
        return snapshot.value as String;
      }
    }

    // Return a default/fallback value if no profile picture is set
    return '';
  }
}