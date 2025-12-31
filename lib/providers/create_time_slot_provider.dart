import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateSlotProvider extends ChangeNotifier {
  bool isLoading = false;

  Future<ApiResponse> createSlot({
    required String date,
    required String startTime,
    required String endTime,
    required String totalSeats,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('provider_auth_token');

      if (token == null || token.isEmpty) {
        throw Exception("Auth token missing");
      }

      final uri = Uri.parse(
        "https://api.call4help.in/cyber/provider/slots/create",
      );


      final payload = {
        "date": date,
        "start_time": startTime,
        "end_time": endTime,
        "total_seats": int.parse(totalSeats),
      };

      print("======================================");
      print("🟦 CREATE SLOT");
      print("🌐 URL: $uri");
      print("🧾 PAYLOAD: $payload");

      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      print("📡 STATUS: ${response.statusCode}");
      print("📦 BODY: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: decoded['message'] ?? "Slot created successfully",
        );
      }

      return ApiResponse(
        success: false,
        message: decoded['message'] ?? "Failed to create slot",
      );
    } catch (e, stack) {
      print("🔥 CREATE SLOT ERROR: $e");
      print(stack);
      return ApiResponse(success: false, message: e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
      print("🛑 CREATE SLOT FLOW ENDED");
      print("======================================");
    }
  }


  Future<ApiResponse> autoGenerateSlots({
    required String date,
    required int durationMinutes,
    required int bufferMinutes,
    required int seatsPerSlot,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('provider_auth_token');

      if (token == null || token.isEmpty) {
        throw Exception("Auth token missing");
      }

      final uri = Uri.parse(
        "https://api.call4help.in/cyber/provider/slots/auto-generate",
      );

      final payload = {
        "date": date,
        "durationMinutes": durationMinutes,
        "bufferMinutes": bufferMinutes,
        "seatsPerSlot": seatsPerSlot,
      };

      print("======================================");
      print("🟩 AUTO GENERATE SLOTS");
      print("🌐 URL: $uri");
      print("🧾 PAYLOAD: $payload");

      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      print("📡 STATUS: ${response.statusCode}");
      print("📦 BODY: ${response.body}");

      final decoded = jsonDecode(response.body);


      if (response.statusCode == 200 || response.statusCode == 201) {

        return ApiResponse(

          success: true,
          message: decoded['message'] ?? "Slots generated successfully",
        );
      }

      return ApiResponse(
        success: false,
        message: decoded['message'] ?? "Failed to auto-generate slots",
      );
    } catch (e, stack) {
      print("🔥 AUTO GENERATE ERROR: $e");
      print(stack);
      return ApiResponse(success: false, message: e.toString());
    } finally {

      isLoading = false;
      notifyListeners();
      print("🛑 AUTO GENERATE FLOW ENDED");
      print("======================================");
    }
  }


}

class ApiResponse {
  final bool success;
  final String message;

  ApiResponse({required this.success, required this.message});
}
