import 'dart:convert';
import 'package:first_flutter/data/models/slot_list_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SlotListProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<SlotListModel> slots = [];
  SlotListModel? selectedSlot;

  Future<void> fetchSlots(String date) async {
    print("📡 fetchSlots called");
    print("📅 Date: $date");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final url = Uri.parse(
        'https://api.call4help.in/cyber-service/provider/slots/list?date=$date',
      );

      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('provider_auth_token');

      print("🌐 GET URL: $url");
      print("🔐 Provider Auth Token: $authToken");

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      print("📥 Status Code: ${response.statusCode}");
      print("📥 Raw Response: ${response.body}");

      final decoded = jsonDecode(response.body);
      print("🧾 Decoded Response: $decoded");

      if (response.statusCode == 200 && decoded['success'] == true) {
        slots = (decoded['data'] as List)
            .map((e) => SlotListModel.fromJson(e))
            .toList();

        print("✅ Slots Loaded: ${slots.length}");
      } else {
        error = 'Failed to load slots';
        print("❌ API Error: $error");
      }
    } catch (e) {
      error = e.toString();
      print("🔥 Exception in fetchSlots: $error");
    }

    isLoading = false;
    notifyListeners();

    print("🏁 fetchSlots completed");
  }

  void selectSlot(SlotListModel slot) {
    selectedSlot = slot;
    notifyListeners();
  }
}
