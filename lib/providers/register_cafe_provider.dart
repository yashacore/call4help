import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterCafeProvider extends ChangeNotifier {
  bool isLoading = false;

  Future<bool> registerCafe({
    required String shopName,
    required String ownerName,
    required String phone,
    required String email,
    required String city,
    required String state,
    required String pincode,
    required String addressLine1,
    required String addressLine2,
    required String latitude,
    required String longitude,
    required String totalComputers,
    required String openingTime,
    required String closingTime,
    required String gstNumber,
    required String documentPath, // local file path
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('provider_auth_token');

      final uri = Uri.parse(
        "https://api.call4help.in/cyber-service/api/cyber/provider/cafe/register",
      );

      print("🌐 Register Cafe URL: $uri");

      final request = http.MultipartRequest("POST", uri);

      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      request.fields.addAll({
        "shop_name": shopName,
        "owner_name": ownerName,
        "phone": phone,
        "email": email,
        "city": city,
        "state": state,
        "pincode": pincode,
        "address_line1": addressLine1,
        "address_line2": addressLine2,
        "latitude": latitude,
        "longitude": longitude,
        "total_computers": totalComputers,
        "opening_time": openingTime,
        "closing_time": closingTime,
        "gst_number": gstNumber,
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          "documents",
          documentPath,
        ),
      );

      print("📤 Sending registration request...");

      final streamedResponse = await request.send();
      final response =
      await http.Response.fromStream(streamedResponse);

      print("📡 Status Code: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print("✅ Cafe registered successfully");
          return true;
        }
      }
    } catch (e) {
      print("🔥 Error registering cafe: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return false;
  }
}
