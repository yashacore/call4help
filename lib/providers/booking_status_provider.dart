import 'dart:convert';
import 'package:first_flutter/data/models/pending_list_booking.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProviderSlotsStatusProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  List<PendingSlotBooking> bookings = [];
  String currentStatus = 'pending';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('provider_auth_token');
  }

  /// ================= FETCH BY STATUS =================
  Future<void> fetchByStatus(String status) async {
    currentStatus = status;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token missing");

      final response = await http.get(
        Uri.parse(
          'https://api.call4help.in/cyber/provider/slots/provider/$status',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        bookings = (decoded['data'] as List)
            .map((e) => PendingSlotBooking.fromJson(e))
            .toList();
      } else {
        error = decoded['message'] ?? 'Failed to load bookings';
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  /// ================= FETCH ALL BOOKINGS =================
  Future<void> fetchAllBookings() async {
    print("📡 ===== FETCH ALL BOOKINGS START =====");

    isLoading = true;
    notifyListeners();

    try {
      print("🔑 Getting auth token...");
      final token = await _getToken();

      if (token == null) {
        print("❌ ERROR: Token missing");
        throw Exception("Token missing");
      }

      print("✅ Token received");

      final url = 'https://api.call4help.in/cyber/provider/slots/bookings';
      print("🌐 GET URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("📡 STATUS CODE: ${response.statusCode}");
      print("📦 RAW RESPONSE: ${response.body}");

      final decoded = jsonDecode(response.body);

      print("🔍 DECODED RESPONSE: $decoded");

      if (response.statusCode == 200 && decoded['success'] == true) {
        bookings = (decoded['data'] as List)
            .map((e) => PendingSlotBooking.fromJson(e))
            .toList();

        print("✅ BOOKINGS LOADED SUCCESSFULLY");
        print("📊 TOTAL BOOKINGS COUNT: ${bookings.length}");
      } else {
        print("❌ API ERROR: ${decoded['message']}");
      }
    } catch (e, stack) {
      print("🔥 EXCEPTION IN fetchAllBookings()");
      print("❗ ERROR: $e");
      print("📍 STACKTRACE: $stack");
    }

    isLoading = false;
    notifyListeners();

    print("🏁 ===== FETCH ALL BOOKINGS END =====");
  }

  /// ================= APPROVE =================
  Future<void> approveBooking({
    required String orderId,
    required String notes,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token missing");

      final response = await http.post(
        Uri.parse(
          'https://api.call4help.in/cyber/provider/slots/provider/approve',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "order_id": orderId,
          "notes": notes,
        }),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        await fetchByStatus('accepted');
        return;
      }
    } catch (e) {
      debugPrint("Approve error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// ================= REJECT =================
  Future<void> rejectBooking(String orderId) async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token missing");

      await http.post(
        Uri.parse(
          'https://api.call4help.in/cyber/provider/slots/provider/reject',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"order_id": orderId}),
      );

      await fetchByStatus('pending');
    } catch (e) {
      debugPrint("Reject error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// ================= COMPLETE =================
  Future<void> completeBooking({
    required String orderId,
    required String notes,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token missing");

      final response = await http.post(
        Uri.parse(
          'https://api.call4help.in/cyber/provider/slots/provider/complete',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "order_id": orderId,
          "notes": notes,
        }),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        await fetchByStatus('completed');

        return;
      }
    } catch (e) {
      debugPrint("Complete error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
