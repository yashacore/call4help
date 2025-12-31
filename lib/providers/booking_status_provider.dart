import 'dart:convert';
import 'package:first_flutter/data/models/pending_list_booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProviderSlotsStatusProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  List<PendingSlotBooking> bookings = [];
  String currentStatus = 'pending';

  Future<void> fetchByStatus(String status) async {
    print("📡 fetchByStatus called with status: $status");

    currentStatus = status;
    isLoading = true;
    error = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('provider_auth_token');

    print("🔐 Auth Token: $authToken");

    try {
      final url =
          'https://api.call4help.in/cyber/provider/slots/provider/$status';
      print("🌐 GET URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      print("📥 Status Code: ${response.statusCode}");
      print("📥 Raw Response: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        bookings = (decoded['data'] as List)
            .map((e) => PendingSlotBooking.fromJson(e))
            .toList();

        print("✅ Bookings Loaded: ${bookings.length}");
      } else {
        error = 'Failed to load $status bookings';
        print("❌ API Error: $error");
      }
    } catch (e) {
      error = e.toString();
      print("🔥 Exception: $error");
    }

    isLoading = false;
    notifyListeners();
  }

  // Future<bool> acceptBooking(String orderId) async {
  //   return _approveBooking(
  //     orderId: orderId,
  //     notes: "Booking approved for customer",
  //   );
  // }

  Future<void> acceptBooking(String orderId) async {
    print("✅ approve booking pressed for orderId: $orderId");
    await _action(orderId, 'approve');
  }

  void showErrorSnackBar(String message, BuildContext? context) {
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Future<bool> approveBooking({
    required String orderId,
    required String notes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('provider_auth_token');

      if (token == null || token.isEmpty) {
        throw Exception("Auth token missing");
      }

      final uri = Uri.parse(
        "https://api.call4help.in/cyber/provider/slots/provider/approve",
      );

      final payload = {"order_id": orderId, "notes": notes};

      print("======================================");
      print("✅ APPROVE BOOKING");
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

      return response.statusCode == 200 && decoded['success'] == true;
    } catch (e, stack) {
      showErrorSnackBar("error$e", null);
      print("🔥 APPROVE ERROR: $e");
      print(stack);
      return false;
    }
  }

  Future<void> rejectBooking(String orderId) async {
    print("❌ Reject booking pressed for orderId: $orderId");
    await _action(orderId, 'reject');
  }

  Future<void> completeBooking(String orderId) async {
    print("✔ Complete booking pressed for orderId: $orderId");
    await _action(orderId, 'complete');
  }

  Future<void> _action(String orderId, String action) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('provider_auth_token');

    final url =
        'https://api.call4help.in/cyber/provider/slots/provider/$action';

    print("➡ ACTION: $action");
    print("🌐 POST URL: $url");
    print("🔐 Token: $authToken");
    print("📦 Payload: { order_id: $orderId }");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'order_id': orderId}),
      );

      print("📥 Action Status Code: ${response.statusCode}");
      print("📥 Action Response: ${response.body}");

      if (response.statusCode == 200) {
        fetchByStatus(currentStatus);
      }
    } catch (e) {
      print("🔥 Action Exception: $e");
    }
  }
}
