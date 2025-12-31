import 'dart:convert';
import 'package:first_flutter/data/models/pending_list_booking.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PendingSlotsProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<PendingSlotBooking> pendingBookings = [];

  Future<void> fetchPendingSlots() async {
    isLoading = true;
    error = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('provider_auth_token');
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.call4help.in/cyber/provider/slots/provider/pending',
        ),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_TOKEN'
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        pendingBookings = (decoded['data'] as List)
            .map((e) => PendingSlotBooking.fromJson(e))
            .toList();
      } else {
        error = 'Failed to load pending slots';
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
