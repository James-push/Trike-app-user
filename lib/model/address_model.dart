class AddressModel {
  String? readableAddress;
  double? latitudePosition;
  double? longitudePosition;
  String? placeID;
  String? placeName;

  // New fields to capture street and block
  String? street;
  String? block;

  AddressModel({
    this.readableAddress,
    this.latitudePosition,
    this.longitudePosition,
    this.placeID,
    this.placeName,
    this.street,      // Add street
    this.block,       // Add block
  });
}
