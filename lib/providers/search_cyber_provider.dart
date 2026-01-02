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
    print('🔍 loadStaticCafes() called');
    print('📍 Search city: "$city"');

    if (city.trim().isEmpty) {
      print('⚠️ City is empty, aborting API call');
      return;
    }

    isLoading = true;
    error = null;
    hasSearched = true;
    notifyListeners();

    try {
      print('🧠 Getting SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      print('🔐 User auth token: ${token != null ? "FOUND" : "NOT FOUND"}');

      final url =
          'https://api.call4help.in/cyber/api/user/cafes/search?city=${Uri.encodeComponent(city)}';

      print('🌐 API URL: $url');
      print('🚀 Sending GET request...');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response Status Code: ${response.statusCode}');
      print('📄 Raw Response Body: ${response.body}');

      final decoded = jsonDecode(response.body);
      print('🧩 Decoded JSON: $decoded');

      if (response.statusCode == 200 && decoded['success'] == true) {
        print('✅ API Success – Parsing cafes list');

        final List data = decoded['data'] ?? [];
        print('📦 Total cafes received: ${data.length}');

        cafes = data.map<Map<String, dynamic>>((e) {
          print('☕ Parsing cafe item: $e');

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

        print('📚 Final cafes list length: ${cafes.length}');
        print('📚 Cafes data: $cafes');
      } else {
        print('❌ API returned failure');
        cafes.clear();
        error = decoded['message'] ?? 'Failed to search cafes';
        print('❌ Error message: $error');
      }
    } catch (e, stackTrace) {
      cafes.clear();
      error = 'Something went wrong';

      print('🔥 EXCEPTION OCCURRED');
      print('🔥 Error: $e');
      print('🔥 StackTrace: $stackTrace');
    }

    isLoading = false;
    notifyListeners();

    print('🔚 loadStaticCafes() completed');
    print('🔄 isLoading: $isLoading');
  }

  void reset() {
    hasSearched = false;
    cafes.clear();
    error = null;
    notifyListeners();
  }
}
