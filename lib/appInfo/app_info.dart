import 'package:flutter/cupertino.dart';
import 'package:user_application/model/address_model.dart';
import '../model/suggestions_model.dart';

class AppInfo extends ChangeNotifier {
  List<SuggestionsModel> _suggestions = [];

  List<SuggestionsModel> get suggestions => _suggestions;

  AddressModel? pickUpLocation;
  AddressModel? destinationLocation;

  void updatePickUpLocation(AddressModel pickUpModel) {
    pickUpLocation = pickUpModel;
    notifyListeners();
  }

  void updateDestinationLocation(AddressModel destinationModel) {
    destinationLocation = destinationModel;
    notifyListeners();
  }

  void updateSuggestions(List<SuggestionsModel> newSuggestions) {
    _suggestions = newSuggestions;
    notifyListeners();
  }

  void clearLocations() {
    pickUpLocation = null;
    destinationLocation = null;
    notifyListeners();
  }

}