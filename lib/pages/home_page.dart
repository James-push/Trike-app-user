import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user_application/pages/menu_page.dart';

import '../global.dart';
import '../methods/googlemap_methods.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
//change
class _HomePageState extends State<HomePage> {
  double containerHeight = 100;
  double bottomPadding = 0;
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionUser;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;

  // Controller for DraggableScrollableSheet
  final DraggableScrollableController _draggableController = DraggableScrollableController();

  // Displaying the user's current location
  Future<void> getCurrentLocation() async {
    Position userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionUser = userPosition;

    LatLng userLatLng = LatLng(currentPositionUser!.latitude, currentPositionUser!.longitude);
    CameraPosition positionCamera = CameraPosition(target: userLatLng, zoom: 18);
    print("\n\nCoordinates: $userLatLng\n\n");
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(positionCamera));
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Future<void> onGPSButtonPressed() async {
    await getCurrentLocation();

    if (currentPositionUser != null) {
      String readableAddress = await GoogleMapMethods.getReadableAddress(currentPositionUser!, context);
      print("User's readable address: $readableAddress");
    }
  }

  // Expands the draggable bottom sheet when "Where to?" button is pressed
  void _expandBottomSheet() {
    _draggableController.animateTo(
      0.8, // Expand to 80% of the screen height
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    ///Overlays top status bar and bottom navbar
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: [SystemUiOverlay.bottom]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      key: sKey,
      drawer: const Drawer(
        child: MenuPage(),
      ),
      body: Stack(
        children: [
          /// Google Maps
          Positioned.fill(
            child: GoogleMap(
              padding: EdgeInsets.only(top: 26, bottom: bottomPadding),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: false, // Disable the built-in GPS button
              zoomControlsEnabled: false, // Disable the built-in Zoom button
              initialCameraPosition: kGooglePlex,
              onMapCreated: (GoogleMapController mapController) {
                controllerGoogleMap = mapController;
                googleMapCompleterController.complete(controllerGoogleMap);
                getCurrentLocation();
              },
            ),
          ),

          /// Custom GPS button
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 122,
            right: 16,
            child: Container(
              width: 46.0, // Standard size for a circular button
              height: 46.0, // Standard size for a circular button
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // Background color
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26, // Shadow color
                    blurRadius: 8.0, // Blur radius
                    spreadRadius: 0.2, // Spread radius
                    offset: Offset(2, 6), // Offset of the shadow
                  ),
                ],
              ),
              child: IconButton(
                onPressed: onGPSButtonPressed,
                icon: const Icon(Icons.my_location, color: Colors.black),
              ),
            ),
          ),

          ///hamburger button
          Positioned(
            top: 60.0, // Adjust this value as needed
            left: 16.0, // Adjust this value as needed
            child: Container(
              width: 46.0, // Standard size for a circular button
              height: 46.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // Background color of the circle
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26, // Shadow color
                    blurRadius: 2.0, // Blur radius
                    spreadRadius: 0.4, // Spread radius
                    offset: Offset(0, 1), // Offset of the shadow
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.menu, size: 24.0, color: Colors.black87), // Adjust icon color
                onPressed: () {
                  sKey.currentState?.openDrawer(); // Open the drawer
                },
              ),
            ),
          ),

          /// Draggable Scrollable Rounded Modal Bottom Sheet
          DraggableScrollableSheet(
            controller: _draggableController,
            initialChildSize: 0.135, // Initial collapsed size
            minChildSize: 0.135, // Minimum size when collapsed
            maxChildSize: 0.8, // Maximum size when expanded
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x76000018), // Shadow color
                      blurRadius: 8.0, // Blur radius
                      spreadRadius: 3.0, // Spread radius
                      offset: Offset(0, 4), // Offset of the shadow
                    ),
                  ],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    /// "Where to?" button inside the bottom sheet
                    GestureDetector(
                      onTap: _expandBottomSheet, // Expands the bottom sheet when pressed
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 20), // Add padding at the top to move it up
                        child: Container(
                          height: 50.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.grey.shade200,
                          ),
                          child: const Center(
                            child: Text(
                              'Where to?',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Add more widgets as per your need
                  ],
                ),
              );
            },
          ),
        ],
      ),

      /// Bottom Navigation Bar
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
          currentIndex: selectedIndex,
          selectedItemColor: Colors.black87,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          enableFeedback: false,
        ),
      ),
    );
  }
}
