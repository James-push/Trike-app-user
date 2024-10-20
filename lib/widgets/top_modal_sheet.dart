import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:user_application/global.dart';
import 'package:user_application/widgets/suggestions_places_ui.dart';
import '../appInfo/app_info.dart';
import '../methods/geocoding_methods.dart';
import '../model/address_model.dart';
import '../model/suggestions_model.dart';
import '../pages/order_tracking_state_page.dart';

class TopModalSheet extends StatefulWidget {
  final Widget child;

  const TopModalSheet({super.key, required this.child});

  @override
  _TopModalSheetState createState() => _TopModalSheetState();
}

class _TopModalSheetState extends State<TopModalSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  // Add focus nodes to track focus state
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  // Add TextEditingControllers for the locations
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  List<SuggestionsModel> destinationPlacesList = [];

  bool showMyLocationSuggestion = false;

  void _populateTextFields(SuggestionsModel suggestion, bool isPickup) {
    setState(() {
      if (isPickup) {
        _pickupController.text = suggestion.title!;

        // Update the pickup location in AppInfo
        Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(
          AddressModel(
            readableAddress: suggestion.title,
            placeName: suggestion.title,
            latitudePosition: suggestion.lat,
            longitudePosition: suggestion.lng,
          ),
        );
      } else {
        _destinationController.text = suggestion.title!;

        // Update the destination location in AppInfo
        Provider.of<AppInfo>(context, listen: false).updateDestinationLocation(
          AddressModel(
            readableAddress: suggestion.title,
            latitudePosition: suggestion.lat,
            longitudePosition: suggestion.lng,
          ),
        );
      }

      // Navigate if both locations are set
      if (_pickupController.text.isNotEmpty && _destinationController.text.isNotEmpty) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => OrderTrackingStatePage(
            pickupAddress: AddressModel(
              readableAddress: _pickupController.text,
              latitudePosition: Provider.of<AppInfo>(context, listen: false)
                  .pickUpLocation?.latitudePosition, // Correct pickup lat
              longitudePosition: Provider.of<AppInfo>(context, listen: false)
                  .pickUpLocation?.longitudePosition, // Correct pickup lng
            ),
            destinationAddress: AddressModel(
              readableAddress: _destinationController.text,
              latitudePosition: Provider.of<AppInfo>(context, listen: false)
                  .destinationLocation?.latitudePosition, // Correct destination lat
              longitudePosition: Provider.of<AppInfo>(context, listen: false)
                  .destinationLocation?.longitudePosition, // Correct destination lng
            ),
          ),
        ));
      }
    });
  }

  ///Places API - Places AutoSuggest for Selecting Destination
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
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    // Request focus for the destination field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_destinationFocusNode);
    });

    // Listen to the focus changes to trigger UI updates
    _pickupFocusNode.addListener(() {
      setState(() {});
    });
    _destinationFocusNode.addListener(() {
      setState(() {});
    });

    // Listen to text changes to show the clear icon
    _pickupController.addListener(() {
      setState(() {});
    });
    _destinationController.addListener(() {
      setState(() {});
    });

    /// Fetch the current location and update the pick-up field
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pickUpLocation = Provider.of<AppInfo>(context, listen: false).pickUpLocation;

      if (pickUpLocation != null) {
        String address = pickUpLocation.placeName ?? "Loading...";
        setState(() {
          _pickupController.text = address.length > 25 ? address.substring(0, 25) + '...' : address;
        });
      }

      Provider.of<AppInfo>(context, listen: false).addListener(() {
        final updatedPickUpLocation = Provider.of<AppInfo>(context, listen: false).pickUpLocation;
        if (updatedPickUpLocation != null) {
          setState(() {
            _pickupController.text = updatedPickUpLocation.placeName ?? "Unknown Location";
          });
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _fetchInitialLocation();
      });
    });
  }

  Future<void> _fetchInitialLocation() async {
    // Use the current context to get the location
    final location = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    // Update the pickup controller with the readable address
    final address = await GeocodingMethods.getReadableAddress(location, context);
    _pickupController.text = address.length > 25 ? address.substring(0, 25) + '...' : address;
  }

  @override
  void dispose() {
    _controller.dispose();
    _pickupFocusNode.dispose();
    _destinationFocusNode.dispose();
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  // Function to clear the text in the corresponding text field
  void _clearText(FocusNode focusNode, TextEditingController controller) {
    if (focusNode.hasFocus) {
      controller.clear();
      setState(() {
        destinationPlacesList.clear();
      }); // Update the UI
    }
  }

  // Function to build location circle indicator
  Widget _buildLocationIndicator({required bool hasValue, required bool isFocused}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (hasValue && !isFocused)
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x344BAE50),
            ),
            child: const Icon(
              Icons.circle,
              color: Colors.green,
              size: 18,
            ),
          ),
        if (isFocused)
          const Icon(
            Icons.search_rounded,
            color: Colors.black87,
            size: 24,
          ),
        if (!hasValue && !isFocused)
          const Icon(
            Icons.circle_outlined,
            color: Colors.black54,
            size: 24,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SlideTransition(
          position: _offsetAnimation,
          child: Material(
            type: MaterialType.transparency,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.25,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3.0,
                      spreadRadius: 0.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    widget.child,
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 2,
                      left: 56,
                      child: const Text(
                        'Your route',
                        style: TextStyle(
                          letterSpacing: 1.5,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    /// Pick up location
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 40,
                      left: 12,
                      right: 12,
                      child: TextField(
                        controller: _pickupController,
                        focusNode: _pickupFocusNode,
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
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto',
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search pick-up location',
                          hintStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Roboto',
                            color: Colors.black54,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: _buildLocationIndicator(
                              hasValue: _pickupController.text.isNotEmpty,
                              isFocused: _pickupFocusNode.hasFocus,
                            ),
                          ),
                          suffixIcon: (_pickupFocusNode.hasFocus && _pickupController.text.isNotEmpty)
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.black54),
                            onPressed: () => _clearText(_pickupFocusNode, _pickupController),
                          )
                              : null,
                          filled: true,
                          fillColor: _pickupFocusNode.hasFocus ? Colors.transparent : Colors.grey.shade200,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.green, width: 2.0),
                          ),
                        ),
                      ),
                    ),
                    /// Drop off location
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 100,
                      left: 12,
                      right: 12,
                      child: TextField(
                        controller: _destinationController,
                        focusNode: _destinationFocusNode,
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
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto',
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Destination',
                          hintStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Roboto',
                            color: Colors.black54,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: _buildLocationIndicator(
                              hasValue: _destinationController.text.isNotEmpty,
                              isFocused: _destinationFocusNode.hasFocus,
                            ),
                          ),
                          suffixIcon: (_destinationFocusNode.hasFocus && _destinationController.text.isNotEmpty)
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.black54),
                            onPressed: () => _clearText(_destinationFocusNode, _destinationController),
                          )
                              : null,
                          filled: true,
                          fillColor: _destinationFocusNode.hasFocus ? Colors.transparent : Colors.grey.shade200,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.green, width: 2.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        /// Displaying suggestion results for destination places
        Positioned(
          top: MediaQuery.of(context).size.height * 0.21, // Adjust this value to position below the top modal sheet
          left: 0,
          right: 0,
          child: (destinationPlacesList.isNotEmpty)
              ? Padding(
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
                    // Check which TextField is focused
                    if (_pickupFocusNode.hasFocus) {
                      _populateTextFields(destinationPlacesList[index], true); // For pickup
                    } else if (_destinationFocusNode.hasFocus) {
                      _populateTextFields(destinationPlacesList[index], false); // For destination
                    }

                    // Optionally clear suggestions after selection
                    setState(() {
                      destinationPlacesList.clear();
                    });
                  },
                );
              },
            ),
          )
              : Container(),
        ),
      ],
    );
  }
}