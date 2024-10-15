import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/address_model.dart';

class OrderTrackingStatePage extends StatefulWidget {
  final AddressModel pickupAddress;
  final AddressModel destinationAddress;

  const OrderTrackingStatePage({Key? key, required this.pickupAddress, required this.destinationAddress}) : super(key: key);

  @override
  State<OrderTrackingStatePage> createState() => _OrderTrackingStatePageState();
}

class _OrderTrackingStatePageState extends State<OrderTrackingStatePage> {
  double containerHeight = 100;
  double bottomPadding = 0;

  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionUser;

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  final DraggableScrollableController _draggableController = DraggableScrollableController();

  Set<Marker> markers = {};

  Future<void> getCurrentLocation() async {
    try {
      Position userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      currentPositionUser = userPosition;

      LatLng userLatLng = LatLng(currentPositionUser!.latitude, currentPositionUser!.longitude);
      CameraPosition positionCamera = CameraPosition(target: userLatLng, zoom: 18);

      if (controllerGoogleMap != null) {
        await controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(positionCamera));
      }
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    addMarkers();
    moveCameraToFitMarkers();
  }

  Future<void> addMarkers() async {
    // Clear existing markers
    markers.clear();



    // Marker for pickup location
    if (widget.pickupAddress.latitudePosition != null &&
        widget.pickupAddress.longitudePosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup_marker'),
          position: LatLng(
            widget.pickupAddress.latitudePosition!,
            widget.pickupAddress.longitudePosition!,
          ),
          infoWindow: InfoWindow(
            title: 'Pickup Location',
            snippet: widget.pickupAddress.readableAddress,
          ),
        ),
      );
    } else {
      print("Pickup coordinates are null");
    }

    // Marker for destination location
    if (widget.destinationAddress.latitudePosition != null &&
        widget.destinationAddress.longitudePosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination_marker'),
          position: LatLng(
            widget.destinationAddress.latitudePosition!,
            widget.destinationAddress.longitudePosition!,
          ),
          infoWindow: InfoWindow(
            title: 'Destination Location',
            snippet: widget.destinationAddress.readableAddress,
          ),
        ),
      );
    } else {
      print("Destination coordinates are null");
    }

    // Trigger rebuild to update the markers on the map
    setState(() {});
  }



  void moveCameraToFitMarkers() {
    if (markers.isNotEmpty) {
      LatLngBounds bounds;
      LatLng? pickupLatLng;
      LatLng? destinationLatLng;

      if (widget.pickupAddress.latitudePosition != null &&
          widget.pickupAddress.longitudePosition != null) {
        pickupLatLng = LatLng(
          widget.pickupAddress.latitudePosition!,
          widget.pickupAddress.longitudePosition!,
        );
      }

      if (widget.destinationAddress.latitudePosition != null &&
          widget.destinationAddress.longitudePosition != null) {
        destinationLatLng = LatLng(
          widget.destinationAddress.latitudePosition!,
          widget.destinationAddress.longitudePosition!,
        );
      }

      if (pickupLatLng != null && destinationLatLng != null) {
        bounds = LatLngBounds(
          southwest: LatLng(
            pickupLatLng.latitude < destinationLatLng.latitude
                ? pickupLatLng.latitude
                : destinationLatLng.latitude,
            pickupLatLng.longitude < destinationLatLng.longitude
                ? pickupLatLng.longitude
                : destinationLatLng.longitude,
          ),
          northeast: LatLng(
            pickupLatLng.latitude > destinationLatLng.latitude
                ? pickupLatLng.latitude
                : destinationLatLng.latitude,
            pickupLatLng.longitude > destinationLatLng.longitude
                ? pickupLatLng.longitude
                : destinationLatLng.longitude,
          ),
        );
      } else if (pickupLatLng != null) {
        bounds = LatLngBounds(
          southwest: pickupLatLng,
          northeast: pickupLatLng,
        );
      } else {
        return;
      }

      controllerGoogleMap?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    // Add logic to retrieve polyline points if necessary
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              padding: EdgeInsets.only(top: 26, bottom: bottomPadding),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.pickupAddress.latitudePosition ?? 0.0,
                  widget.pickupAddress.longitudePosition ?? 0.0,
                ),
                zoom: 15.0,
              ),
              markers: markers, // Set the markers here
              onMapCreated: (GoogleMapController mapController) {
                controllerGoogleMap = mapController;
                googleMapCompleterController.complete(controllerGoogleMap);
              },
            ),
          ),
          DraggableScrollableSheet(
            controller: _draggableController,
            initialChildSize: 0.165,
            minChildSize: 0.165,
            maxChildSize: 1,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x76000018),
                      blurRadius: 8.0,
                      spreadRadius: 3.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: ElevatedButton(
                        onPressed: () {
                          print("Request Ride button pressed!");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BF63),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          minimumSize: Size(screenWidth * 0.9, 48),
                        ),
                        child: const Text(
                          'Request Ride',
                          style: TextStyle(
                            letterSpacing: 0.5,
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
