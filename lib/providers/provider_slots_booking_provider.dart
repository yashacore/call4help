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
    required String totalAmount,
    required String baseAmount,
    required String extraCharges,
    required String discountAmount,
    required Map<String, dynamic> inputFields,
    required List<Map<String, String>> uploadedFiles,
  }) async {
    debugPrint('📘 [bookSlot] Method started');

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      debugPrint('🔐 [bookSlot] Fetching auth token');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      debugPrint('🔐 [bookSlot] Token exists: ${token != null && token.isNotEmpty}');
      if (token == null || token.isEmpty) {
        throw Exception("Token missing");
      }

      final payload = {
        "slot_id": slotId,
        "subcategory_id": subcategoryId,
        "total_amount": totalAmount,
        "base_amount": baseAmount,
        "extra_charges": extraCharges,
        "discount_amount": discountAmount,
        "input_fields": inputFields,
        "uploaded_files": uploadedFiles,
      };

      debugPrint('🌐 [bookSlot] POST URL: https://api.call4help.in/cyber/provider/slots/book');
      debugPrint('📦 [bookSlot] Request payload: $payload');

      final response = await http.post(
        Uri.parse('https://api.call4help.in/cyber/provider/slots/book'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      debugPrint('📡 [bookSlot] Status code: ${response.statusCode}');
      debugPrint('📦 [bookSlot] Raw response body: ${response.body}');

      final decoded = jsonDecode(response.body);
      debugPrint('📦 [bookSlot] Decoded response: $decoded');

      if (response.statusCode == 200 && decoded['success'] == true) {
        debugPrint('✅ [bookSlot] Booking successful');

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = decoded['message'] ?? "Booking failed";
        debugPrint('❌ [bookSlot] Booking failed: $error');
      }
    } catch (e, stackTrace) {
      error = e.toString();
      debugPrint('🔥 [bookSlot] Exception occurred: $e');
      debugPrint('📌 [bookSlot] StackTrace: $stackTrace');
    }

    isLoading = false;
    notifyListeners();

    debugPrint('📘 [bookSlot] Method ended with failure');
    return false;
  }

}
