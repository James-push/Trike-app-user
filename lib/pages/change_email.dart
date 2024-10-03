import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangeEmailPage extends StatefulWidget {
  @override
  _ChangeEmailPageState createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _changeEmail() async {
    final String currentPassword = _currentPasswordController.text.trim();
    final String newEmail = _newEmailController.text.trim();
    User? user = _auth.currentUser;

    if (user == null) {
      _showErrorDialog("No user is currently signed in.");
      return;
    }

    if (currentPassword.isEmpty || newEmail.isEmpty) {
      _showErrorDialog("Please enter both the current password and new email address.");
      return;
    }

    if (!user.emailVerified) {
      _showErrorDialog("Please verify your current email before updating.");
      return;
    }

    try {
      // Reauthenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update email
      await user.updateEmail(newEmail);
      await user.reload();
      user = _auth.currentUser; // Refresh user

      // Send email verification to the new email
      await user?.sendEmailVerification();

      _showSuccessDialog("Email address updated successfully. Please check your new email to verify the change.");
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");

      // Handle specific FirebaseAuth exceptions
      String message = '';
      switch (e.code) {
        case 'wrong-password':
          message = 'The current password is incorrect.';
          break;
        case 'invalid-email':
          message = 'The new email address is not valid.';
          break;
        case 'email-already-in-use':
          message = 'The new email address is already in use.';
          break;
        case 'invalid-credential':
          message = 'The current password is incorrect.';
          break;
        case 'operation-not-allowed':
          message = 'This operation is not allowed. Please check your Firebase settings.';
          break;
        case 'too-many-requests':
          message = 'Too many requests. Please try again later.';
          await Future.delayed(Duration(seconds: 60)); // Wait 1 minute
          // Optionally retry the operation here
          break;
        default:
          message = 'An error occurred. Please try again.\n\nError code: ${e.code}';
      }
      _showErrorDialog(message);
    } catch (e) {
      _showErrorDialog("An error occurred. Please try again.\n\nError: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Change Email",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Current Password",
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0), // Default gray color
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0), // Default gray color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.green, width: 2.0), // Green when focused
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "New Email Address",
                prefixIcon: const Icon(
                    Icons.email,
                    color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey, width: 1.0), // Default gray color
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey, width: 1.0), // Default gray color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.green, width: 2.0), // Green when focused
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changeEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 75, 201, 104),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: const Text("Change Email"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
