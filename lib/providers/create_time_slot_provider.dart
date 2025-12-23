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
    print("🔵 createSlot() called");
    print("➡️ date: $date");
    print("➡️ startTime: $startTime");
    print("➡️ endTime: $endTime");
    print("➡️ totalSeats: $totalSeats");

    isLoading = true;
    notifyListeners();
    print("⏳ isLoading = true");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('provider_auth_token');

      print("🔐 Token present: ${token != null && token.isNotEmpty}");

      final uri = Uri.parse(
        "https://api.call4help.in/cyber-service/api/provider/slots/create-slot",
      );

      print("🌐 API URL: $uri");

      final requestBody = {
        "date": date,
        "start_time": startTime,
        "end_time": endTime,
        "total_seats": int.parse(totalSeats),
      };

      print("📤 Request Body: $requestBody");

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(requestBody),
      );

      print("📡 Status Code: ${response.statusCode}");
      print("📦 Raw Response Body: ${response.body}");

      final data = json.decode(response.body);
      print("✅ Decoded JSON: $data");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("🎉 Slot created successfully");
        return ApiResponse(
          success: data['success'] ?? true,
          message: data['message'] ?? "Slot created successfully",
        );
      }

      print("❌ Slot creation failed (API error)");
      return ApiResponse(
        success: false,
        message: data['message'] ?? "Failed to create slot",
      );
    } catch (e) {
      print("🔥 Exception in createSlot(): $e");
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      isLoading = false;
      notifyListeners();
      print("✅ isLoading = false");
    }
  }
}

class ApiResponse {
  final bool success;
  final String message;

  ApiResponse({required this.success, required this.message});
}
