import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match your splash background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/app_icon.png', // Your splash image
              width: 150, // Adjust the size as needed
            ),
            const SizedBox(height: 20),
            const Text(
              'Trike',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Adjust the color as needed
              ),
            ),
          ],
        ),
      ),
    );
  }
}
