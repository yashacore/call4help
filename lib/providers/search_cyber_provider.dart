import 'package:flutter/material.dart';

class CyberCafeProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  bool hasSearched = false; // ⭐ KEY FLAG
  List<Map<String, String>> cafes = [];

  /// STATIC DATA (for testing)
  final List<Map<String, String>> _allCafes = [
    {
      "name": "Cyber Zone",
      "address": "MP Nagar, Bhopal",
      "city": "bhopal",
    },
    {
      "name": "Digital Cafe",
      "address": "New Market, Bhopal",
      "city": "bhopal",
    },
    {
      "name": "Net World",
      "address": "Indrapuri, Bhopal",
      "city": "bhopal",
    },
    {
      "name": "Fast Net Cafe",
      "address": "Vijay Nagar, Indore",
      "city": "indore",
    },
  ];

  void loadStaticCafes({required String city}) {
    hasSearched = true;
    isLoading = true;
    error = null;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 300), () {
      cafes = _allCafes
          .where((cafe) =>
          cafe['city']!.toLowerCase().contains(city.toLowerCase()))
          .toList();

      isLoading = false;
      notifyListeners();
    });
  }

  void reset() {
    hasSearched = false;
    cafes.clear();
    notifyListeners();
  }
}
