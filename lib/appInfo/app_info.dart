import 'package:flutter/cupertino.dart';
import 'package:user_application/model/address_model.dart';

class AppInfo extends ChangeNotifier
{
  AddressModel? pickUpLocation;
  AddressModel? destinationLocation;

  void updatePickUpLocation(AddressModel pickUpModel)
  {
    pickUpLocation = pickUpModel;
    notifyListeners();
  }

  void updateDestinationLocation(AddressModel destinationModel)
  {
    destinationLocation = destinationModel;
    notifyListeners();
  }
}