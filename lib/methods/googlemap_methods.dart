import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:user_application/appInfo/app_info.dart';
import 'package:user_application/global.dart';
import 'package:http/http.dart' as http;
import 'package:user_application/model/address_model.dart';


class GoogleMapMethods {
  static sendRequestToAPI(String apiURL) async {
    http.Response responseFromAPI = await http.get(Uri.parse(apiURL));

    try {
      if (responseFromAPI.statusCode == 200) {
        String dataFromAPI = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromAPI);
        return dataDecoded;
      } else {
        return "error";
      }
    } catch (errorMsg) {
      print("\n\nError Occurred::\n$errorMsg\n\n");
      return "error";
    }
  }

  /// Reverse GeoCoding with HERE API
  static Future<String> getReadableAddress(Position position, BuildContext context) async {
    String readableAddress = "";
    String street = "";
    String block = "";

    String geoCodingAPIURL =
        "https://revgeocode.search.hereapi.com/v1/revgeocode?at=${position.latitude},${position.longitude}&apikey=$hereAPIKey";

    double userLatitude = position.latitude;
    double userLongitude = position.longitude;

    var responseFromAPI = await sendRequestToAPI(geoCodingAPIURL);

    try {
      if (responseFromAPI != "error") {
        print("Full Response: $responseFromAPI");

        print("Latitude: $userLatitude, Longitude: $userLongitude");

        // Extract readable address
        var addressInfo = responseFromAPI['items'][0];
        readableAddress = addressInfo['address']['label'];
        print("readableAddress = $readableAddress");

        // Extract specific components like street, block, etc.
        street = addressInfo['address']['street'] ?? "Street not found";
        block = addressInfo['address']['district'] ?? "Block not found";

        print("Street: $street");
        print("Block: $block");

        AddressModel addressModel = AddressModel();
        addressModel.readableAddress = readableAddress;
        addressModel.placeName = readableAddress;
        addressModel.placeID = addressInfo["id"];
        addressModel.latitudePosition = position.latitude;
        addressModel.longitudePosition = position.longitude;

        Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(addressModel);
      } else {
        print("\n\nError occurred\n\n");
      }
    } catch (e) {
      print("\n\nERROR HERE:: \n$e\n");
      return "error";
    }

    return readableAddress;
  }
}
