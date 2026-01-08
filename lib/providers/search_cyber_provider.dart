import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CyberCafeProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  bool hasSearched = false;

  /// ✅ Correct type
  List<Map<String, dynamic>> cafes = [];

  static const String baseUrl = 'https://api.call4help.in/cyber';

  Future<void> loadStaticCafes({required String city}) async {

    if (city.trim().isEmpty) {
      return;
    }

    isLoading = true;
    error = null;
    hasSearched = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');


      final url =
          'https://api.call4help.in/cyber/api/user/cafes/search?city=${Uri.encodeComponent(city)}';


      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );


      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {

        final List data = decoded['data'] ?? [];

        cafes = data.map<Map<String, dynamic>>((e) {

          return {
            'id': e['id'],
            'shop_name': (e['shop_name'] ?? '')
                .toString()
                .replaceAll('"', ''),
            'address': e['address_line1'] ?? '',
            'city': e['city'] ?? '',
            'available_computers': e['available_computers'] ?? 0,
          };
        }).toList();

      } else {
        cafes.clear();
        error = decoded['message'] ?? 'Failed to search cafes';
      }
    } catch (e, stackTrace) {
      cafes.clear();
      error = 'Something went wrong';

    }

    isLoading = false;
    notifyListeners();

  }

  void reset() {
    hasSearched = false;
    cafes.clear();
    error = null;
    notifyListeners();
  }
}
