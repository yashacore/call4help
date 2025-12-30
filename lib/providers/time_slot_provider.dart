import 'dart:convert';
import 'package:first_flutter/data/models/time_slot_model.dart';
// ignore: unused_import
import 'package:first_flutter/screens/user_screens/cyber_cafe/time_slot_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SlotProvider extends ChangeNotifier {
  List<TimeSlot> slots = [];
  bool isLoading = false;
  String? selectedSlotId;

  Future<void> fetchSlots({
    required String cyberCafeId,
    required String date,
  }) async {
    print("🔵 fetchSlots() called");
    print("➡️ cyberCafeId: $cyberCafeId");
    print("➡️ date: $date");

    isLoading = true;
    notifyListeners();
    print("⏳ Loading started");

    final url =
        'https://api.call4help.in/cyber/provider/slots/slots'
        '?cyber_cafe_id=$cyberCafeId&date=$date';

    print("🌐 API URL: $url");
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');

    try {
      final response = await http.get(Uri.parse(url
      ),
        headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
        }, );

      print("📡 Response status code: ${response.statusCode}");
      print("📦 Raw response body: ${response.body}");

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        print("✅ JSON decoded successfully");

        print("🔍 success flag: ${body['success']}");

        if (body['success'] == true) {
          final data = body['data'] as List;
          print("📊 Slots received: ${data.length}");

          slots = data.map((e) {
            print(
              "🕒 Slot → ${e['start_time']} - ${e['end_time']} | "
                  "Seats: ${e['available_seats']} | Locked: ${e['is_locked']}",
            );
            return TimeSlot.fromJson(e);
          }).toList();

          print("✅ Slots parsed & stored successfully");
        } else {
          print("❌ API success = false");
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("🔥 Exception in fetchSlots(): $e");
    }

    isLoading = false;
    notifyListeners();
    print("✅ Loading finished");
  }

  Future<void> bookSlot() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    if (selectedSlotId == null) {
      print("❌ No slot selected");
      return;
    }

    print("🟢 bookSlot() called");
    print("➡️ Slot ID: $selectedSlotId");

    isLoading = true;
    notifyListeners();

    final url =
        'https://api.call4help.in/cyber-service/provider/slots/book';

    final body = {
      "slot_id": selectedSlotId,
      "subcategory_id": "57",
      "total_amount": 500,
      "base_amount": 400,
      "extra_charges": 5,
      "discount_amount": -5,
      "input_fields": {
        "duration": "1 hour",
        "pc_type": "gaming"
      },
      "uploaded_files": [
        {
          "file_name": "aadhar.pdf",
          "file_url": "https://example.com/aadhar.pdf"
        }
      ]
    };

    print("🌐 Booking API URL: $url");
    print("📤 Request Body: $body");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("📡 Status Code: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);

        if (responseBody['success'] == true) {
          print("✅ Slot booked successfully");
        } else {
          print("❌ Booking failed: ${responseBody['message']}");
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("🔥 Exception in bookSlot(): $e");
    }

    isLoading = false;
    notifyListeners();
  }


  void selectSlot(String id) {
    selectedSlotId = id;
    notifyListeners();
  }

  void showSuccessSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


}
