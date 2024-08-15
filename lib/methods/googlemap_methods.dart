import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:user_application/appInfo/app_info.dart';
import 'package:user_application/global.dart';
import 'package:http/http.dart' as http;
import 'package:user_application/model/address_model.dart';

class GoogleMapMethods {
  static sendRequestToAPI(String apiURL) async
  {
    http.Response responseFromAPI = await http.get(Uri.parse(apiURL));

    try
    {
      if (responseFromAPI.statusCode == 200)
      {
        String dataFromAPI = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromAPI);
        return dataDecoded;
      }
      else
      {
        return "error";
      }
    }
    catch (errorMsg)
    {
      print("\n\nError Occurred::\n$errorMsg\n\n");
      return "error";
    }
  }

  /// Reverse GeoCoding
  static Future<String> convertGeoGraphicCoordinatesToReadableAddress(
      Position position, BuildContext context) async {
    String readableAddress = "";
    String geoCodingAPIURL = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";

    var responseFromAPI = await sendRequestToAPI(geoCodingAPIURL);

    try
    {
      if (responseFromAPI != "error")
      {
        readableAddress = responseFromAPI["results"][0]["formatted_address"];
        print("readableAddress = " + readableAddress);

        AddressModel addressModel = AddressModel();
        addressModel.readableAddress = readableAddress;
        addressModel.placeName = readableAddress;
        addressModel.placeID = responseFromAPI["results"][0]["place_id"];
        addressModel.latitudePosition = position.latitude;
        addressModel.longitudePosition = position.longitude;

        Provider.of<AppInfo>(context, listen: false)
            .updatePickUpLocation(addressModel);
      }
    }
    catch(e)
    {
      print("ERROR HERE: " + e.toString());
    }


    return readableAddress;
  }
}
