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
  notCreated,
}

/// ================= UI SLOT MODEL =================
class SlotUIModel {
  final String startTime;
  final String endTime;
  final SlotUIStatus status;
  final TimeSlot? apiSlot;

  SlotUIModel({
    required this.startTime,
    required this.endTime,
    required this.status,
    this.apiSlot,
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
    int startHour = 9,
    int endHour = 18,
  }) async {
    debugPrint("🚀 ===== fetchFullDaySlots START =====");
    debugPrint("🏪 Cyber Cafe ID: $cyberCafeId");
    debugPrint("📅 Date: $date");
    debugPrint("⏰ Time Range: $startHour:00 - $endHour:00");

    isLoading = true;
    notifyListeners();

    try {
      /// 🔑 Token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      debugPrint("🔑 Token exists: ${token != null}");

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
      final List<dynamic> data = decoded['data'] ?? [];

      debugPrint("📊 API Slots Count: ${data.length}");

      /// 🔄 Parse API slots
      final List<TimeSlot> apiSlots =
      data.map((e) => TimeSlot.fromJson(e)).toList();

      for (final s in apiSlots) {
        debugPrint(
          "🕒 API Slot → ${s.startTime}-${s.endTime} | "
              "Seats: ${s.availableSeats}/${s.availableSeats} | "
              "Locked: ${s.isLocked}",
        );
      }

      /// 🗂 Map slots by time
      final Map<String, TimeSlot> slotMap = {
        for (var s in apiSlots)
          "${s.startTime}-${s.endTime}": s
      };

      final List<SlotUIModel> result = [];

      /// ⏱️ Generate 30-minute slots
      for (int h = startHour; h < endHour; h++) {
        for (int m = 0; m < 60; m += 30) {
          final start =
              "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:00";
          final endMinute = m + 30;
          final end =
              "${h.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00";

          final key = "$start-$end";

          if (slotMap.containsKey(key)) {
            final slot = slotMap[key]!;

            final status = slot.isLocked
                ? SlotUIStatus.locked
                : slot.availableSeats == 0
                ? SlotUIStatus.full
                : SlotUIStatus.available;

            debugPrint("✅ MATCH → $key | Status: $status");

            result.add(
              SlotUIModel(
                startTime: start,
                endTime: end,
                apiSlot: slot,
                status: status,
              ),
            );
          } else {
            debugPrint("❌ NO SLOT → $key");

            result.add(
              SlotUIModel(
                startTime: start,
                endTime: end,
                status: SlotUIStatus.notCreated,
              ),
            );
          }
        }
      }

      debugPrint("📊 Final UI Slots Count: ${result.length}");
      slots = result;

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
