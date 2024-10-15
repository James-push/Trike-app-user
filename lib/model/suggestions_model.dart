class SuggestionsModel {
  String? id; // Equivalent to place_id in Google API
  String? title; // Equivalent to main_text
  String? address; // Equivalent to secondary_text
  double? lat;
  double? lng;

  SuggestionsModel({
    this.id,
    this.title,
    this.address,
    this.lat,
    this.lng,
  });

  SuggestionsModel.fromJson(Map<String, dynamic> json) {
    id = json["id"]; // Place ID in HERE API
    title = json["title"]; // The main place name or title

    // Check if address exists and has a label
    if (json["address"] != null && json["address"]["label"] != null) {
      address = json["address"]["label"]; // Full address text
    } else {
      address = "Address not available"; // Default message or handle null
    }

    // Ensure position is present before accessing lat/lng
    if (json["position"] != null) {
      lat = json["position"]["lat"]; // Latitude
      lng = json["position"]["lng"]; // Longitude
    } else {
      lat = null; // or a default value
      lng = null; // or a default value
    }
  }
}
