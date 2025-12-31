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
      id: json['id']?.toString() ?? '',
      shopName: json['shop_name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      address: json['address_line1']?.toString() ?? '',

      /// 🔥 SAFE NUMBER PARSING
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,

      availableComputers: json['available_computers'] ?? 0,

      /// distance_meters can be int OR double
      distanceMeters:
      (json['distance_meters'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
