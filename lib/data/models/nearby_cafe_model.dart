class NearbyCafeModel {
  final String id;
  final String shopName;
  final String city;
  final String state;
  final String address;
  final double latitude;
  final double longitude;
  final int availableComputers;
  final double distanceMeters;

  NearbyCafeModel({
    required this.id,
    required this.shopName,
    required this.city,
    required this.state,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.availableComputers,
    required this.distanceMeters,
  });

  factory NearbyCafeModel.fromJson(Map<String, dynamic> json) {
    return NearbyCafeModel(
      id: json['id'],
      shopName: json['shop_name'],
      city: json['city'],
      state: json['state'],
      address: json['address_line1'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      availableComputers: json['available_computers'],
      distanceMeters: double.parse(json['distance_meters']),
    );
  }
}
