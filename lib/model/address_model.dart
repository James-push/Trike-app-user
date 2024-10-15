class AddressModel {
  String? readableAddress;
  double? latitudePosition;
  double? longitudePosition;
  String? placeID;
  String? placeName;
  String? street;
  String? houseNumber;
  String? district;
  String? city;
  String? county;
  String? postalCode;

  AddressModel({
    this.readableAddress,
    this.latitudePosition,
    this.longitudePosition,
    this.placeID,
    this.placeName,
    this.street,
    this.houseNumber,
    this.district,
    this.city,
    this.county,
  });
}
