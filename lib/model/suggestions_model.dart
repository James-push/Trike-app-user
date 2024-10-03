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
    address = json["address"]["label"]; // Full address text
    lat = json["position"]["lat"]; // Latitude
    lng = json["position"]["lng"]; // Longitude
  }
}
