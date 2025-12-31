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
        'https://api.call4help.in/cyber/provider/slots/list?date=$date',
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


  Future<bool> deleteSlot(String slotId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('provider_auth_token');

      if (token == null || token.isEmpty) {
        throw Exception("Auth token missing");
      }

      final uri = Uri.parse(
        "https://api.call4help.in/cyber/provider/slots/delete/$slotId",
      );

      print("======================================");
      print("🗑️ DELETE SLOT");
      print("🌐 URL: $uri");

      final response = await http.delete(
        uri,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print("📡 STATUS: ${response.statusCode}");
      print("📦 BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      error = "Failed to delete slot";
      return false;
    } catch (e) {
      error = e.toString();
      print("🔥 DELETE SLOT ERROR: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
      print("🛑 DELETE SLOT FLOW ENDED");
      print("======================================");
    }
  }

}
