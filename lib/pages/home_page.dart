import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../appInfo/app_info.dart';
import '../global.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double containerHeight = 100;
  double bottomPadding = 0;
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionUser;

  int selectedIndex = 0;

  // Displaying the user's current location
  Future<void> getCurrentLocation() async {
    Position userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionUser = userPosition;

    LatLng userLatLng = LatLng(currentPositionUser!.latitude, currentPositionUser!.longitude);
    CameraPosition positionCamera = CameraPosition(target: userLatLng, zoom: 18);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(positionCamera));
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      // Handle navigation or actions based on the selected index here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onPressed: getCurrentLocation,
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
              decoration: BoxDecoration(
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
                icon: Icon(Icons.menu, size: 24.0, color: Colors.black87), // Adjust icon color
                onPressed: () {
                  print("Hamburger button pressed");
                },
              ),
            ),
          ),

          /// Draggable Search Container
          DraggableScrollableSheet(
            initialChildSize: 0.125, // Initial size of the sheet when collapsed
            minChildSize: 0.125, // Minimum size (collapsed)
            maxChildSize: 0.2, // Maximum size (expanded)
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Draggable handle at the top
                    Container(
                      height: 5.0,
                      width: 50.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Color(0xffe5e5e5),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
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
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
