import 'package:flutter/material.dart';

class CyberCafeProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  bool hasSearched = false;
  List<Map<String, String>> cafes = [];

  final List<Map<String, String>> _allCafes = [
    {"name": "Cyber Zone", "address": "MP Nagar, Bhopal", "city": "delhi"},
    {"name": "Digital Cafe", "address": "New Market, Bhopal", "city": "mumbai"},
    {"name": "Net World", "address": "Indrapuri, Bhopal", "city": "bhopal"},
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
          .where(
            (cafe) => cafe['city']!.toLowerCase().contains(city.toLowerCase()),
          )
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
