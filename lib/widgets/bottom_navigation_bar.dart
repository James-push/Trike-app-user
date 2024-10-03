import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pages/edit_profile.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/trips_page.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of pages to switch between
  final List<Widget> _pages = [
    const HomePage(),
    const TripsPage(),
    const ProfilePage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages, // Display the current page based on index
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x18000018), // Shadow color
              blurRadius: 8.0, // Blur radius
              spreadRadius: 3.0, // Spread radius
              offset: Offset(0, 4), // Offset of the shadow
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              label: 'Trips',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: onItemTapped, // Assign the function directly here
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          enableFeedback: false,
        ),
      ),
    );
  }
}
