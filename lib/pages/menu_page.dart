import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:user_application/methods/user_service.dart';
import 'package:user_application/widgets/logout_dialog.dart';
import '../methods/custom_page_route.dart';
import '../widgets/loading_dialog.dart';
import 'about_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  Future<String> fetchUserName() async {
    final userId = await UserService.instance.getCurrentUserId();
    if (userId == null) {
      return 'Unknown User';
    }

    final DataSnapshot snapshot = await FirebaseDatabase.instance.ref('users/$userId').get();
    return snapshot.exists && snapshot.value is Map<dynamic, dynamic>
        ? (snapshot.value as Map<dynamic, dynamic>)['name'] ?? 'Unknown User'
        : 'Unknown User';
  }

  Future<void> logOut(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => const LoadingDialog(messageTxt: "Please wait..."),
    );

    await Future.delayed(const Duration(seconds: 1));

    try {
      await UserService.instance.logout(context);
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xffefefef),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildNavigationList(context),
            const SizedBox(height: 8),
            _buildLogOutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24.0)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xffefefef),
            backgroundImage: null, // Replace with your profileUrl logic
            child: Icon(Icons.person, size: 28, color: Colors.grey),
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
                return _buildUserNameSection(snapshot.data);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserNameSection(String? userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => print('Name clicked'),
          child: Text(
            userName ?? 'Unknown User',
            style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () {}, // Navigate to ProfilePage
          child: const Text(
            'My Account',
            style: TextStyle(color: Colors.green),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationList(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24.0)),
      ),
      child: Column(
        children: [
          _buildListTile(context, Icons.notifications_none_rounded, 'Notification'),
          _buildListTile(context, Icons.schedule_rounded, 'My Rides'),
          _buildListTile(context, Icons.help_outline_rounded, 'Support'),
          _buildAboutTile(context),
        ],
      ),
    );
  }

  ListTile _buildListTile(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: SizedBox(
        width: 40,
        child: Icon(icon, color: Colors.black54),
      ),
      title: Text(title, style: const TextStyle(color: Colors.black87)),
      onTap: () => print(title),
    );
  }

  ListTile _buildAboutTile(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 40,
        child: const Icon(Icons.info_outline_rounded, color: Colors.black54),
      ),
      title: const Text('About', style: TextStyle(color: Colors.black87)),
      onTap: () {
        Navigator.push(
          context,
          CustomPageRoute(page: AboutPage()), // Use your custom route
        );
      },

    );
  }

  Widget _buildLogOutSection(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
        ),
        child: Column(
          children: [
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Icon(Icons.logout_rounded, color: Colors.black54),
              ),
              title: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text('Log out', style: TextStyle(color: Colors.black87)),
              ),
              onTap: () => LogoutDialog.showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
