import 'dart:convert';
import 'package:first_flutter/data/models/nearby_cafe_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class NearbyCafesProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<NearbyCafeModel> cafes = [];

  Future<void> fetchNearbyCafes() async {
    print("📡 fetchNearbyCafes started");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final position = await LocationService.getCurrentLocation();

      print("📍 Current Location → "
          "Lat: ${position.latitude}, Lng: ${position.longitude}");

      final url = Uri.parse(
        'https://api.call4help.in/cyber/api/user/cafes/nearby'
            '?lat=${position.latitude}'
            '&lng=${position.longitude}'
            '&radius=50',
      );

      debugPrint("🌐 API URL: $url");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint("📥 Status Code: ${response.statusCode}");
      debugPrint("📥 Response: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        cafes = (decoded['data'] as List)
            .map((e) => NearbyCafeModel.fromJson(e))
            .toList();

        debugPrint("✅ Cafes Found: ${cafes.length}");

        /// 🔥 PRINT CYBER CAFE IDs
        for (final cafe in cafes) {
          debugPrint("🏪 Cyber Cafe ID: ${cafe.id}");
        }
      } else {
        error = 'Failed to load nearby cafes';
      }
    } catch (e) {
      error = e.toString();
      print("🔥 Error: $error");
    }

    isLoading = false;
    notifyListeners();
    print("🏁 fetchNearbyCafes finished");
  }

}




class LocationService {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
