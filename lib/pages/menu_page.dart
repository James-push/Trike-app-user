import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:user_application/methods/user_service.dart';
import 'package:user_application/pages/profile_page.dart';

import '../widgets/loading_dialog.dart';
import 'about_page.dart'; // Ensure this path is correct

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  final String? profileUrl = null; // Assume this value comes from user data (null means no profile picture)

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

  Future<void> logOut(BuildContext context) async {

    showDialog(
        context: context,
        builder: (BuildContext context) => LoadingDialog(messageTxt: "Logging out...")

    );
    // Introduce a small delay (e.g., 1 second) to ensure the dialog is displayed
    await Future.delayed(const Duration(seconds: 1));

    try {
      await UserService.instance.logout(context);
      // Navigate to login or splash screen
      Navigator.pushReplacementNamed(context, '/login'); //navigates to login screen
    } catch (e) {
      print("Error signing out: $e");
      // Optionally show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xffefefef), // Set the background color of the Drawer to grey
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Name & Profile Picture
            Container(
              width: double.infinity, // Full width of the drawer
              height: 150, // Set a fixed height for the container
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white, // Background color of the header
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22, // Adjust the size to fit
                    backgroundColor: const Color(0xffefefef),
                    backgroundImage: profileUrl != null
                        ? NetworkImage(profileUrl!)
                        : null, // Use the URL if available, otherwise show fallback
                    child: profileUrl == null
                        ? const Icon(Icons.person, size: 28, color: Colors.grey,) // Default fallback icon
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: fetchUserName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(child: Text('Error fetching name'));
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0), // Adjust this value to move the name down
                              child: InkWell(
                                onTap: () {
                                  // Handle name click
                                  print('Name clicked');
                                  // Navigate to a different page or perform an action
                                },
                                child: Text(
                                  snapshot.data ?? 'Unknown User',
                                  style: const TextStyle(color: Colors.black, fontSize: 18),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () {
                                // Handle account click
                                Navigator.push(context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePage(),
                                    ));
                                // Navigate to a different page or perform an action
                              },
                              child: const Text(
                                'My Account',
                                style: TextStyle(color: Colors.green),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8), // Add spacing between header and list items

            /// Drawer Navigation
            Container(
              decoration: const BoxDecoration(
                color: Colors.white, // Background color for the list items
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const SizedBox(
                      width: 40, // Adjust this value to add space to the left of the icon
                      child: Icon(Icons.notifications_none_rounded, color: Colors.black54),
                    ),
                    title: const Text('Notification', style: TextStyle(color: Colors.black87)),
                    onTap: () => print('Notification'),
                  ),
                  ListTile(
                    leading: const SizedBox(
                      width: 40, // Adjust this value to add space to the left of the icon
                      child: Icon(Icons.schedule_rounded, color: Colors.black54),
                    ),
                    title: const Text('My Rides', style: TextStyle(color: Colors.black87)),
                    onTap: () => print('My Rides'),
                  ),
                  ListTile(
                    leading: const SizedBox(
                      width: 40, // Adjust this value to add space to the left of the icon
                      child: Icon(Icons.help_outline_rounded, color: Colors.black54),
                    ),
                    title: const Text('Support', style: TextStyle(color: Colors.black87)),
                    onTap: () => print('Support'),
                  ),
                  ListTile(
                    leading: const SizedBox(
                      width: 40, // Adjust this value to add space to the left of the icon
                      child: Icon(Icons.info_outline_rounded, color: Colors.black54),
                    ),
                    title: const Text('About', style: TextStyle(color: Colors.black87)),
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(
                            builder: (context) => AboutPage(),
                          ));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8), // Add spacing between header and list items

            /// 2nd Drawer Navigation (Expandable)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white, // Background color for the list items
                  borderRadius: BorderRadius.all(Radius.circular(24.0)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Padding(
                        padding: EdgeInsets.only(left: 10.0), // Adjust the left padding as needed
                        child: Icon(Icons.logout_rounded, color: Colors.black54),
                      ),
                      title: const Padding(
                        padding: EdgeInsets.only(left: 8.0), // Adjust the left padding as needed
                        child: Text('Log out', style: TextStyle(color: Colors.black87)),
                      ),
                      onTap: () => logOut(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
