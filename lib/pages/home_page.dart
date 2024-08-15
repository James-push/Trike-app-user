import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_application/global.dart';
import 'package:user_application/methods/googlemap_methods.dart';


import '../appInfo/app_info.dart';

class HomePage extends StatefulWidget
{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  double bottomPadding = 0;
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionUser;
  double searchContainerHeight = 220;

  //Displaying the user's current location
  getCurrentLocation() async
  {
    Position userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionUser = userPosition;

    LatLng userLatLng = LatLng(currentPositionUser!.latitude, currentPositionUser!.longitude);
    CameraPosition positionCamera = CameraPosition(target: userLatLng, zoom: 15);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(positionCamera));

    await GoogleMapMethods.convertGeoGraphicCoordinatesToReadableAddress(currentPositionUser!, context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(



      body: Stack(
        children: [

          ///google maps
          GoogleMap(
            padding: EdgeInsets.only(top: 26, bottom: bottomPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: kGooglePlex,
            onMapCreated: (GoogleMapController mapController)
            {
              controllerGoogleMap = mapController;
              googleMapCompleterController.complete(controllerGoogleMap);
              getCurrentLocation();
            },
          ),

          ///search location container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 122),
              child: Container(
                height: searchContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(21),
                    topLeft: Radius.circular(21),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [

                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.grey,),
                          const SizedBox(width: 13.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Pick-up location", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
                              Text(
                                ///ternary operator 
                                Provider.of<AppInfo>(context, listen: true).pickUpLocation == null ? "please wait..." : (Provider.of<AppInfo>(context, listen: false).pickUpLocation!.placeName!).substring(0, 20) + "...",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10.0),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 16.0),

                      Row(
                        children: [
                          const Icon(Icons.add_location_alt_outlined, color: Colors.grey,),
                          const SizedBox(width: 13.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("To", style: TextStyle(fontSize: 12),),
                              const Text("Where to go?", style: TextStyle(fontSize: 12),),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10.0),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 16.0),

                      ElevatedButton(
                        onPressed: (){},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                        ),
                        child: const Text(
                          "Select Destination",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),



                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),

    );
  }
}
