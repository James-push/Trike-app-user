import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/error_dialog.dart';
import '../widgets/custom_dialog.dart';

class LocationService {
  // Define your allowed vicinity center and radius (in meters)
  final double allowedLatitude = 15.158227;  // Example latitude
  final double allowedLongitude = 120.588480; // Example longitude
  final double allowedRadius = 300; // 300 meters

  // Function to check user location
  Future<bool> checkUserLocation(BuildContext context) async {
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      double distance = Geolocator.distanceBetween(
        allowedLatitude,
        allowedLongitude,
        position.latitude,
        position.longitude,
      );
      print("DISTANCE IS: $distance");

      if (distance <= allowedRadius) {
        // User is within the allowed vicinity
        print("Allowed to set booking");
        return true;
      } else {
        // User is outside the allowed vicinity
        showDialog(
          context: context,
          builder: (context) {
            return CustomDialog(
              titlemessageTxt: "Service Not Available Here",
              messageTxt: "You need to be inside Sta. Maria Subdivision to use this service.",
              imagePath: 'assets/images/far_icon.png',
              imageSize: 100.0, // Customize the image size
            );
          },
        );
        return false;
      }
    } catch (e) {
      print("Error retrieving location");
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
            titlemessageTxt: "Location Error",
            messageTxt: "We're having trouble retrieving your location. Please check your settings and try again.",
            icon: Icons.location_off_rounded, // Icon of your choice
            iconSize: 40, // Example of setting a larger icon size
          );
        },
      );
      return false;
    }
  }
}
