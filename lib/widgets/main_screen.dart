import 'package:flutter/material.dart';
import 'package:user_application/pages/home_page.dart';
import 'package:user_application/pages/profile_page.dart';
import 'package:user_application/pages/trips_page.dart';
import '../pages/menu_page.dart';
import 'custom_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Widget> _pages; // Declare _pages as a late variable
  late AnimationController _animationController;
  late Animation<double> _animation; // Animation for size
  bool _isBottomNavBarVisible = true; // Default is true to show nav bar

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Adjust duration as needed
    );

    // Animation for size transition
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize the _pages list here
    _pages = [
      HomePage(
        scaffoldKey: _scaffoldKey,
        onNavBarVisibilityChanged: (isVisible) {
          setState(() {
            _isBottomNavBarVisible = isVisible; // Update visibility based on HomePage
            if (isVisible) {
              _animationController.forward(); // Show
            } else {
              _animationController.reverse(); // Hide
            }
          });
        },
      ),
      const TripsPage(),
      const ProfilePage(),
    ];
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void login() async {
    // Your login logic
    // After a successful login
    setState(() {
      _isBottomNavBarVisible = true; // Ensure the nav bar is shown after login
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomNavBarHeight = MediaQuery.of(context).size.height * 0.08; // Adaptive height based on screen height

    return Scaffold(
      key: _scaffoldKey,
      drawer: const Drawer(
        child: MenuPage(), // Use MenuPage as the drawer
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),

          // Hamburger button
          if (_selectedIndex == 0)
            Positioned(
              top: 60.0,
              left: 16.0,
              child: Container(
                width: 46.0,
                height: 46.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2.0,
                      spreadRadius: 0.4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu, size: 24.0, color: Colors.black87),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
            ),
        ],
      ),

      // Using SizeTransition with Box Shadow
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isBottomNavBarVisible ? bottomNavBarHeight : 0, // Adaptive height
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: CustomBottomNavBar(
          currentIndex: _selectedIndex,
          onItemTapped: onItemTapped,
        ),
      ),


    );
  }
}
