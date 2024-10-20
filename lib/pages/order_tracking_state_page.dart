import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../appInfo/app_info.dart';
import '../global.dart';
import '../methods/geocoding_methods.dart';
import '../methods/polyline_service.dart';
import '../model/address_model.dart';
import '../model/suggestions_model.dart';
import '../widgets/suggestions_places_ui.dart';

class OrderTrackingStatePage extends StatefulWidget {
  final AddressModel pickupAddress;
  final AddressModel destinationAddress;

  const OrderTrackingStatePage({
    Key? key,
    required this.pickupAddress,
    required this.destinationAddress,
  }) : super(key: key);

  @override
  State<OrderTrackingStatePage> createState() => _OrderTrackingStatePageState();
}

class _OrderTrackingStatePageState extends State<OrderTrackingStatePage> {
  BitmapDescriptor? pickupIcon;
  BitmapDescriptor? destinationIcon;


  late PolylineService polylineService;
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};

  late double tripDistance;
  final TextEditingController destinationController = TextEditingController();
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;

  List<SuggestionsModel> destinationPlacesList = [];

  ///Populate TextField
  void _populateTextFields(SuggestionsModel suggestion) {
    setState(() {
        destinationController.text = suggestion.title!;

        Provider.of<AppInfo>(context, listen: false).updateDestinationLocation(
          AddressModel(
            readableAddress: suggestion.title,
            latitudePosition: suggestion.lat,
            longitudePosition: suggestion.lng,
          ),
        );
    });
    print("UPDATED LOCATION: ");
    print(AppInfo().destinationLocation?.readableAddress.toString());
  }

  ///Auto Suggest Api
  searchPlace(String userInput) async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    if (userInput.length > 1) {
      // Use the Autosuggest API
      String placesAPIUrl = "https://autosuggest.search.hereapi.com/v1/autosuggest?q=$userInput&at=${position.latitude},${position.longitude}&apiKey=$hereAPIKey";
      // Send request to HERE API
      var responseFromAutoSuggestAPI = await GeocodingMethods.sendRequestToAPI(placesAPIUrl);

      // DEBUGGING: Add this line to check the API response
      print("HERE API Response: $responseFromAutoSuggestAPI");
      print("Request URL: $placesAPIUrl");

      // Handle error case
      if (responseFromAutoSuggestAPI == "error") {
        return;
      }

      // Now parse the response
      // Ensure responseFromAutoSuggestAPI is a String before decoding
      var decodedResponse;
      if (responseFromAutoSuggestAPI is String) {
        decodedResponse = jsonDecode(responseFromAutoSuggestAPI);
      } else {
        decodedResponse = responseFromAutoSuggestAPI; // Already decoded
      }

      // Process suggestions if available
      List<SuggestionsModel> newSuggestionsList = [];
      if (decodedResponse["items"] != null) {
        for (var suggestion in decodedResponse["items"]) {
          newSuggestionsList.add(SuggestionsModel.fromJson(suggestion));
        }
      }
      // Update state with the new suggestions
      setState(() {
        destinationPlacesList = newSuggestionsList; // Use the new list
      });
    } else if (userInput.isEmpty) {
      // If the pickup field is empty, show "My location" suggestion
      setState(() {
        destinationPlacesList = [
          SuggestionsModel(title: "My location") // Add this suggestion
        ];
      });
    }
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    polylineService = PolylineService();
    destinationController.text = widget.destinationAddress.placeName ?? "";
    loadCustomMarkers().then((_) {
      addMarkersAndPolyline();
    });

    // Calculate distance between pickup and destination
    final pickupLatLng = LatLng(
      widget.pickupAddress.latitudePosition!,
      widget.pickupAddress.longitudePosition!,
    );
    final destinationLatLng = LatLng(
      widget.destinationAddress.latitudePosition!,
      widget.destinationAddress.longitudePosition!,
    );
    tripDistance = calculateDistance(pickupLatLng, destinationLatLng);
  }

  ///Custom Markers
  Future<void> loadCustomMarkers() async {
    pickupIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(24, 24)),
      'assets/images/pick_up_icon.png',
    );

    destinationIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(36, 36)),
      'assets/images/destination_icon.png',
    );
  }

  ///Add Route and Markers
  void addMarkersAndPolyline() async {
    markers.clear();
    final pickupLatLng = LatLng(
      widget.pickupAddress.latitudePosition!,
      widget.pickupAddress.longitudePosition!,
    );
    final destinationLatLng = LatLng(
      widget.destinationAddress.latitudePosition!,
      widget.destinationAddress.longitudePosition!,
    );

    markers.add(Marker(
      markerId: const MarkerId('pickup_marker'),
      position: pickupLatLng,
      icon: pickupIcon!,
      infoWindow: InfoWindow(title: 'Pickup Location'),
    ));

    markers.add(Marker(
      markerId: const MarkerId('destination_marker'),
      position: destinationLatLng,
      icon: destinationIcon!,
      infoWindow: InfoWindow(title: 'Destination Location'),
    ));

    final routeCoordinates = await polylineService.fetchRouteCoordinates(pickupLatLng, destinationLatLng);

    if (routeCoordinates.isNotEmpty) {
      drawPolyline(routeCoordinates);
    } else {
      print("No route found or API returned an empty route.");
    }

    setState(() {});
  }

  ///Calculates Distance
  double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // Earth’s radius in kilometers

    final double dLat = _toRadians(end.latitude - start.latitude);
    final double dLng = _toRadians(end.longitude - start.longitude);

    final double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
            cos(_toRadians(start.latitude)) *
                cos(_toRadians(end.latitude)) *
                (sin(dLng / 2) * sin(dLng / 2));

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in kilometers
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  ///Draws the Route
  void drawPolyline(List<LatLng> coordinates) {
    setState(() {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: coordinates,
          color: const Color(0xCB4131E5),
          width: 5,
        ),
      );
    });
  }

  ///Search Destination
  void updateDestination(String placeName) {
    // Logic to update the destination address based on user input
    // For now, just print it (you can integrate with a place search API if needed).
    print('Updated destination: $placeName');
    setState(() {
      widget.destinationAddress.readableAddress = placeName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ///GoogleMap
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            padding: const EdgeInsets.only(top: 100, bottom: 100),
            mapType: MapType.normal,
            polylines: polylines,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.pickupAddress.latitudePosition ?? 0.0,
                widget.pickupAddress.longitudePosition ?? 0.0,
              ),
              zoom: 15.0,
            ),
            markers: markers,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              googleMapCompleterController.complete(mapController);
              moveCameraToFitMarkers();
            },
          ),

          ///Displaying Suggested Places
          Positioned(
            top: MediaQuery.of(context).size.height * 0.08, // Adjust this value to position below the top modal sheet
            left: MediaQuery.of(context).size.width * 0.04, // Left margin
            right: MediaQuery.of(context).size.width * 0.04, // Right margin
            child: (destinationPlacesList.isNotEmpty)
                ? Container(
              decoration: BoxDecoration(
                color: Colors.white, // Background color for the suggestions
                borderRadius: BorderRadius.circular(18), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Shadow color
                    blurRadius: 5, // Blur radius
                    offset: const Offset(0, 2), // Shadow offset
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8), // Padding inside the container
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.separated(
                  itemCount: destinationPlacesList.length > 5 ? 5 : destinationPlacesList.length, // Limit to 6 suggestions
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  separatorBuilder: (BuildContext context, int index) => Divider(
                    color: Colors.grey.shade300, // Divider color
                    thickness: 1, // Thickness of the divider
                    height: 0, // Space around the divider
                  ),
                  itemBuilder: (context, index) {
                    return SuggestionsPlacesUI(
                      suggestionsPlacesData: destinationPlacesList[index],
                      onTap: () {
                          _populateTextFields(destinationPlacesList[index]);
                        // Optionally clear suggestions after selection
                        setState(() {
                          destinationPlacesList.clear();
                        });
                      },
                    );
                  },
                ),
              ),
            )
                : Container(),
          ),

          ///Search Destination
          Positioned(
            top: MediaQuery.of(context).size.height * 0.03,
            left: MediaQuery.of(context).size.width * 0.04,
            right: MediaQuery.of(context).size.width * 0.04,
            child: SafeArea(
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: destinationController,
                          onChanged: (userInput) {
                            if(userInput.isEmpty)
                            {
                              setState(() {
                                destinationPlacesList.clear();
                              });
                            }
                            else
                            {
                              searchPlace(userInput);
                            }
                          },
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search destination',
                            hintStyle: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        updateDestination(destinationController.text);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          ///Sheet, Request Ride Button, Infos
          DraggableScrollableSheet(
            initialChildSize: 0.165,
            minChildSize: 0.165,
            maxChildSize: 1,
            builder: (context, scrollController) {
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
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 10, ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Circular Icon on the Left
                        Container(
                          width: 24, // Adjusted size for better alignment
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xCB4034B6), // Custom color for the icon
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.circle,
                              color: Colors.white,
                              size: 14, // Adjusted icon size for balance
                            ),
                          ),
                        ),
                        const SizedBox(width: 14), // Adjusted spacing between icon and text

                        // Place Name and Distance
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: widget.destinationAddress.readableAddress ?? "Destination",
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' • ',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black54,
                                  ),
                                ),
                                TextSpan(
                                  text: '${tripDistance.toStringAsFixed(2)} km',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Request Ride Button
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ElevatedButton(
                          onPressed: () {
                            print("Request Ride button pressed!");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BF63),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            minimumSize: const Size(48, 48),
                          ),
                          child: const Text(
                            'Request Ride',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
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

          ///Gps Button
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 142,
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
                onPressed: moveCameraToFitMarkers,
                icon: const Icon(Icons.my_location, color: Colors.black),
              ),
            ),
          ),


        ],
      ),
    );
  }

  void moveCameraToFitMarkers() {
    if (markers.isNotEmpty) {
      LatLngBounds bounds;
      final pickupLatLng = LatLng(
        widget.pickupAddress.latitudePosition!,
        widget.pickupAddress.longitudePosition!,
      );
      final destinationLatLng = LatLng(
        widget.destinationAddress.latitudePosition!,
        widget.destinationAddress.longitudePosition!,
      );

      bounds = LatLngBounds(
        southwest: LatLng(
          pickupLatLng.latitude < destinationLatLng.latitude ? pickupLatLng.latitude : destinationLatLng.latitude,
          pickupLatLng.longitude < destinationLatLng.longitude ? pickupLatLng.longitude : destinationLatLng.longitude,
        ),
        northeast: LatLng(
          pickupLatLng.latitude > destinationLatLng.latitude ? pickupLatLng.latitude : destinationLatLng.latitude,
          pickupLatLng.longitude > destinationLatLng.longitude ? pickupLatLng.longitude : destinationLatLng.longitude,
        ),
      );

      controllerGoogleMap?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    }
  }
}
