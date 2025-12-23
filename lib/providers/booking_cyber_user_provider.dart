import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingCyberServiceProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<Booking> bookings = [];

  Future<void> fetchBookings() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('https://api.call4help.in/cyber-service/api/user/dashboard/bookings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        bookings = (decoded['data'] as List)
            .map((e) => Booking.fromJson(e))
            .toList();
      } else {
        error = 'Failed to load bookings';
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
class Booking {
  final String id;
  final String status;
  final String paymentStatus;
  final String totalAmount;
  final String shopName;
  final String city;
  final String date;
  final String startTime;
  final String endTime;

  Booking({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.shopName,
    required this.city,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      status: json['status'],
      paymentStatus: json['payment_status'],
      totalAmount: json['total_amount'],
      shopName: json['cafe']['shop_name'],
      city: json['cafe']['city'],
      date: json['slot']['date'],
      startTime: json['slot']['start_time'],
      endTime: json['slot']['end_time'],
    );
  }
}
