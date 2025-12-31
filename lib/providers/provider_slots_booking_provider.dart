import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProviderSlotBookingProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  Future<bool> bookSlot({
    required String slotId,
    required String subcategoryId,
    required int totalAmount,
    required int baseAmount,
    required int extraCharges,
    required int discountAmount,
    required Map<String, dynamic> inputFields,
    required List<Map<String, String>> uploadedFiles,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception("Token missing");

      final response = await http.post(
        Uri.parse('https://api.call4help.in/cyber/provider/slots/book'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "slot_id": slotId,
          "subcategory_id": subcategoryId,
          "total_amount": totalAmount,
          "base_amount": baseAmount,
          "extra_charges": extraCharges,
          "discount_amount": discountAmount,
          "input_fields": inputFields,
          "uploaded_files": uploadedFiles,
        }),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = decoded['message'] ?? "Booking failed";
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
    return false;
  }
}
