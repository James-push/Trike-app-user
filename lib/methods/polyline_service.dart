import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class PolylineService {
  Future<List<LatLng>> fetchRouteCoordinates(LatLng origin, LatLng destination) async {
    final url = 'https://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?geometries=polyline';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<LatLng> polylineCoordinates = [];

      if (data['routes'].isNotEmpty) {
        final polyline = data['routes'][0]['geometry'];
        polylineCoordinates = decodePolyline(polyline);
      } else {
        print("No routes found in the response.");
      }

      return polylineCoordinates;
    } else {
      print('Failed to fetch route: ${response.body}');
      return [];
    }
  }

  List<LatLng> decodePolyline(String polyline) {
    List<LatLng> coordinates = [];
    var index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result >> 1) ^ -(result & 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result >> 1) ^ -(result & 1));
      lng += dlng;

      LatLng coordinate = LatLng(lat / 1E5, lng / 1E5);
      coordinates.add(coordinate);
    }

    return coordinates;
  }
}
