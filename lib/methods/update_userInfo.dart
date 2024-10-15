import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../widgets/error_dialog.dart';

// This function is now public and can be accessed from other files
Future<void> updateUserInfo(BuildContext context, TextEditingController nameController, TextEditingController emailController, TextEditingController phoneController) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    // User is not logged in
    showDialog(
      context: context,
      builder: (context) {
        return ErrorDialog(
          titlemessageTxt: "Access Denied.",
          messageTxt: "Please log in to access your account.",
          icon: Icons.no_accounts_outlined, // Icon of your choice
          iconSize: 40, // Example of setting a larger icon size
        );
      },
    );
    return;
  }

  try {
    // Reference to Firebase Storage
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageRef = storage.ref().child('profile_pictures/${user.uid}');

    // Reference to Firebase Realtime Database
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);

    // Update user information in the database
    await userRef.update({
      'name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
    });

    // Check if the email has changed
    if (user.email != emailController.text) {
      // Check if the user has verified their current email
      if (!user.emailVerified) {
        // Send verification email
        await user.sendEmailVerification();
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              titlemessageTxt: "Email Verification Required",
              messageTxt: "We've sent a verification email to your address. Please check your inbox and verify your email before making any changes.",
              icon: Icons.email_outlined, // Icon of your choice
              iconSize: 40, // Example of setting a larger icon size
            );
          },
        );
        return;
      }

      // Once the email is verified, allow the email update
      await user.updateEmail(emailController.text);
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  } catch (e) {
    // Handle errors
    print("Error updating profile: $e");
    showDialog(
      context: context,
      builder: (context) {
        return ErrorDialog(
          titlemessageTxt: "Profile Update Failed.",
          messageTxt: "We encountered an issue while updating your profile. Please try again or check your internet connection",
          icon: Icons.warning_amber_rounded, // Icon of your choice
          iconSize: 40, // Example of setting a larger icon size
        );
      },
    );
  }
}
