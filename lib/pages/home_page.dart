import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user_application/pages/menu_page.dart';
import '../global.dart';
import '../methods/geocoding_methods.dart';
import 'package:user_application/widgets/top_modal_sheet.dart';

import '../methods/location_service.dart';

class HomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(bool) onNavBarVisibilityChanged; // Callback to change nav bar visibility
  const HomePage({Key? key, required this.onNavBarVisibilityChanged, required this.scaffoldKey}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double containerHeight = 100;
  double bottomPadding = 0;
  int selectedIndex = 0;
  bool _isBottomNavBarVisible = true; // State for bottom nav bar visibility

  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionUser;

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  /// Controller for DraggableScrollableSheet
  final DraggableScrollableController _draggableController = DraggableScrollableController();

  ///Visibility for navBar
  bool isBottomNavBarVisible = true; // Manage the visibility state

  /// Displaying the user's current location
  Future<void> getCurrentLocation() async {
    Position userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionUser = userPosition;

    LatLng userLatLng = LatLng(currentPositionUser!.latitude, currentPositionUser!.longitude);
    CameraPosition positionCamera = CameraPosition(target: userLatLng, zoom: 18);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(positionCamera));
  }

  Future<void> onGPSButtonPressed() async {
    await getCurrentLocation();

    if (currentPositionUser != null) {
      String readableAddress = await GeocodingMethods.getReadableAddress(currentPositionUser!, context);
      if (mounted) {
        print("User's readable address: $readableAddress");
      }
    }
  }

  ///top modal sheet
  Future<void> _showCustomTopModal(BuildContext context) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => TopModalSheet(
          child: Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).padding.top - 12,
                left: 2,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: () {
                    widget.onNavBarVisibilityChanged(true); // Show the navbar
                    _draggableController.animateTo(
                      0.1,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
        opaque: false,
        barrierColor: Colors.transparent,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0, -1);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween<Offset>(begin: begin, end: end);
          var offsetAnimation = animation.drive(tween.chain(CurveTween(curve: curve)));

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  /// Expands the draggable bottom and top and validates user's current location when "Where to?" button is pressed
  void expandBottomTopSheet() async {
    LocationService locationService = LocationService();
    // Check if the user is within the allowed vicinity
    bool isInVicinity = await locationService.checkUserLocation(context);


    // Proceed only if the user is within the allowed vicinity
    if (isInVicinity) {
      print("Where to Tapped");
      widget.onNavBarVisibilityChanged(false); // Hide the navbar

      // Start both animations concurrently
      await Future.wait([
        _draggableController.animateTo(
          1.0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        ),
        _showCustomTopModal(context),
      ]);
    }
    // No else needed, as the dialog should already be shown in checkUserLocation method
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
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
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
              width: 46.0,
              height: 46.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    spreadRadius: 0.2,
                    offset: Offset(2, 6),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: getCurrentLocation,
                icon: const Icon(Icons.my_location, color: Colors.black),
              ),
            ),
          ),

          /// Draggable Scrollable Rounded Modal Bottom Sheet
          DraggableScrollableSheet(
            controller: _draggableController,
            initialChildSize: 0.135,
            minChildSize: 0.135,
            maxChildSize: 1,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x76000018),
                      blurRadius:8.0,
                      spreadRadius: 3.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    /// "Where to?" button inside the bottom sheet
                    GestureDetector(
                      onTap: () {
                        expandBottomTopSheet(); // Call your existing method
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 20),
                        child: Container(
                          height: 50.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.grey.shade200,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8.0, left: 8.0),
                                padding: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade300,
                                ),
                                child: const Icon(
                                  Icons.search,
                                  color: Colors.black54,
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  'Where to?',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
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
    );
  }
}
