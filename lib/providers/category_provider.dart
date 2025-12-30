import 'package:first_flutter/config/baseControllers/APis.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../data/models/CatehoryModel.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // Replace with your actual base URL

  Future<void> fetchCategories() async {
    print('📦 fetchCategories() called');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final url = 'https://api.call4help.in/api/admin/categories';
      print('🌐 Request URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response Status Code: ${response.statusCode}');
      print('📄 Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Status 200 - Parsing response');

        final jsonData = json.decode(response.body);
        print('🧩 Decoded JSON: $jsonData');

        final categoryResponse = CategoryResponse.fromJson(jsonData);
        _categories = categoryResponse.categories;

        print('📚 Categories count: ${_categories.length}');
        print('📚 Categories data: $_categories');

        _errorMessage = null;
      } else {
        _errorMessage =
        'Failed to load categories. Status: ${response.statusCode}';

        print('❌ API Error: $_errorMessage');
        _categories = [];
      }
    } catch (e, stackTrace) {
      _errorMessage = 'Error fetching categories: ${e.toString()}';

      print('🔥 Exception occurred while fetching categories');
      print('🔥 Error: $e');
      print('🔥 StackTrace: $stackTrace');

      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();

      print('🔚 fetchCategories() completed');
      print('🔄 isLoading: $_isLoading');
    }
  }

  String getFullImageUrl(String icon) {
    if (icon.isEmpty) {
      return '';
    }
    // Remove leading slash if present
    final cleanIcon = icon.startsWith('/') ? icon.substring(1) : icon;
    return '$base_url/$cleanIcon';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
