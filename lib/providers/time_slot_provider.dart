import 'dart:convert';
import 'package:first_flutter/data/models/time_slot_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ================= UI SLOT STATUS =================
enum SlotUIStatus {
  available,
  full,
  locked,
}

/// ================= UI SLOT MODEL =================
class SlotUIModel {
  final String startTime;
  final String endTime;
  final SlotUIStatus status;
  final TimeSlot apiSlot;

  SlotUIModel({
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.apiSlot,
  });
}

/// ================= PROVIDER =================
class SlotProvider extends ChangeNotifier {
  bool isLoading = false;
  List<SlotUIModel> slots = [];
  String? selectedSlotId;

  /// ================= FETCH FULL DAY SLOTS =================
  Future<void> fetchFullDaySlots({
    required String cyberCafeId,
    required String date,
  }) async {
    debugPrint("🚀 ===== fetchFullDaySlots START =====");
    debugPrint("🏪 Cyber Cafe ID: $cyberCafeId");
    debugPrint("📅 Date: $date");

    isLoading = true;
    slots.clear();
    notifyListeners();

    try {
      /// 🔑 TOKEN
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      debugPrint("🔑 Token exists: ${token != null && token.isNotEmpty}");

      /// 🌐 API URL
      final url =
          'https://api.call4help.in/cyber/provider/slots/slots'
          '?cyber_cafe_id=$cyberCafeId&date=$date';

      debugPrint("🌐 API URL: $url");

      /// 📡 API CALL
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("📥 Status Code: ${response.statusCode}");
      debugPrint("📦 Raw Response: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (decoded['success'] != true) {
        debugPrint("❌ API returned success=false");
        return;
      }

      final List<dynamic> data = decoded['data'] ?? [];
      debugPrint("📊 API Slots Count: ${data.length}");

      /// 🔁 MAP API → UI (1:1)
      slots = data.map<SlotUIModel>((item) {
        final slot = TimeSlot.fromJson(item);

        final SlotUIStatus status;
        if (slot.isLocked) {
          status = SlotUIStatus.locked;
        } else if (slot.availableSeats <= 0) {
          status = SlotUIStatus.full;
        } else {
          status = SlotUIStatus.available;
        }

        debugPrint(
          "🕒 Slot ${slot.startTime}-${slot.endTime} | "
              "Seats: ${slot.availableSeats}/${slot.availableSeats} | "
              "Locked: ${slot.isLocked} | Status: $status",
        );

        return SlotUIModel(
          startTime: slot.startTime,
          endTime: slot.endTime,
          status: status,
          apiSlot: slot,
        );
      }).toList();

      debugPrint("✅ Final UI Slots Count: ${slots.length}");
    } catch (e, stack) {
      debugPrint("🔥 ERROR in fetchFullDaySlots");
      debugPrint("❗ Error: $e");
      debugPrint("📍 Stacktrace: $stack");
    }

    isLoading = false;
    notifyListeners();
    debugPrint("🏁 ===== fetchFullDaySlots END =====");
  }

  /// ================= SELECT SLOT =================
  void selectSlot(String slotId) {
    selectedSlotId = slotId;
    debugPrint("🎯 Selected Slot ID: $slotId");
    notifyListeners();
  }


}
