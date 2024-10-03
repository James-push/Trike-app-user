import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:user_application/pages/home_page.dart';
import 'package:user_application/pages/profile_page.dart';
import '../methods/user_service.dart';
import '../widgets/error_dialog.dart';

// Error dialog
void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => ErrorDialog(messageTxt: message),
  );
}

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  _TripsPageState createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {

  int selectedIndex = 1;

  final String? profileUrl = null; // Assume this value comes from user data (null means no profile picture)

  @override
  void initState() {
    super.initState();
    fetchUserName(); // Fetch user's full name on widget load
  }

  Future<String> fetchUserName() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes default back button
        title: const Text(
          "Trips",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add padding to the left and right
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20), // Add spacing at the top
            Text("Display Trips History Here...")
          ],
        ),
      ),
    );
  }
}


