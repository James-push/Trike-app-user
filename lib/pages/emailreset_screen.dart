import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user_application/authentication/login_screen.dart';

class EmailResetScreen extends StatefulWidget {
  const EmailResetScreen({super.key});

  @override
  _EmailResetScreenState createState() => _EmailResetScreenState();
}

class _EmailResetScreenState extends State<EmailResetScreen> {
  final TextEditingController userEmail = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String? newEmail;

  void _sendEmailVerification() async {
    final String email = userEmail.text.trim();

    if (email.isEmpty) {
      _showErrorDialog("Please enter your email address.");
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(), // Loading spinner
        );
      },
    );

    try {
      final user = auth.currentUser;
      if (user != null) {
        newEmail = email;

        // Send verification email to the new address (without updating Firebase email yet)
        await auth.currentUser?.sendEmailVerification();

        Navigator.of(context).pop(); // Dismiss the loading dialog

        await _showSuccessDialog("A verification email has been sent to your new email address. Please verify it and then return to update your email.");

      } else {
        Navigator.of(context).pop(); // Dismiss the loading dialog
        _showErrorDialog("No user is currently logged in.");
      }
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss the loading dialog
      _showErrorDialog("An error occurred. Please try again.\n\nError code: $e");
    }
  }

  Future<void> _updateEmailAfterVerification() async {

    final String email = userEmail.text.trim();
    newEmail = email;
    if (newEmail == null || newEmail!.isEmpty) {
      _showErrorDialog("No new email to update.");
      return;
    }

    // Ensure user email has been verified
    await auth.currentUser?.reload();
    if (auth.currentUser?.emailVerified == true) {
      try {
        await auth.currentUser?.updateEmail(newEmail!);
        _showSuccessDialog("Your email has been updated successfully.");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } catch (e) {
        _showErrorDialog("Failed to update email. Error: $e");
      }
    } else {
      _showErrorDialog("Please verify your new email before updating.");
    }
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
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
        );
      },
    );
  }

  Future<void> _showSuccessDialog(String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the success dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Update Email",
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
              controller: userEmail,
              decoration: InputDecoration(
                label: const Text("New Email Address"),
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 204, 245, 215), width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 204, 245, 215), width: 2.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendEmailVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 75, 201, 104),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: const Text("Send Verification Email"),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateEmailAfterVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 75, 201, 104),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: const Text("Update Email After Verification"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
