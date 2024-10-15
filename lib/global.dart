import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user_application/methods/validate_method.dart';


ToastMethod toast = ToastMethod();
String userName = "";
String userPhone = "";

String googleAPIKey = "AIzaSyCdVCfL9R-nEpSd7_yzL4QoW_rxyBeeTEI";
String hereAPIKey = "gv8_5HZcxmQwOcWFRYA_fdjEnUGHy-Qp-ZwltqbGTlY";

const CameraPosition kGooglePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

