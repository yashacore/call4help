import 'dart:convert';
import 'package:first_flutter/data/models/cyber_booking_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingDetailProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  BookingDetail? booking;

  Future<void> fetchBookingDetail(String orderId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('https://api.call4help.in/cyber-service/api/user/dashboard/bookings/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        booking = BookingDetail.fromJson(decoded['data']);
      } else {
        error = 'Failed to load booking details';
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
