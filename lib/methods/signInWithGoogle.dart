import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../widgets/main_screen.dart';

class AuthService {
  static Future<void> signInWithGoogle(BuildContext context) async {

    try {
      // Start the Google Sign-In process
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      // Get the authentication details
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      // Create a new credential
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Sign in to Firebase with the credential
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Access user details
      User? user = userCredential.user;

      // Print user's display name for debugging
      print(user?.displayName);

      if (user != null) {
        // Create a reference to the Firebase Realtime Database
        DatabaseReference databaseReference = FirebaseDatabase.instance.ref('users/${user.uid}');

        // Store user data in Realtime Database
        await databaseReference.set({
          'name': user.displayName,
          'email': user.email,
          'phone': "",
          'id': user.uid,
          "blockStatus": "no",
          "role": "passenger",
        });


        // Navigate to the SampleHomePage
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen()));
      }
    } catch (e) {
      print("Error signing in with Google: $e");
    }
  }
}
