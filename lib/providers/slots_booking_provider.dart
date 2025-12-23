import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SlotsBookingsProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<SlotBookingModel> bookings = [];

  Future<void> fetchBookings() async {
    isLoading = true;
    error = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse('https://api.call4help.in/cyber-service/provider/slots/bookings'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        bookings = (decoded['data'] as List)
            .map((e) => SlotBookingModel.fromJson(e))
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
class SlotBookingModel {
  final String id;
  final String status;
  final String paymentStatus;
  final String totalAmount;
  final DateTime createdAt;
  final SlotModel slot;

  SlotBookingModel({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.createdAt,
    required this.slot,
  });

  factory SlotBookingModel.fromJson(Map<String, dynamic> json) {
    return SlotBookingModel(
      id: json['id'],
      status: json['status'],
      paymentStatus: json['payment_status'],
      totalAmount: json['total_amount'],
      createdAt: DateTime.parse(json['created_at']),
      slot: SlotModel.fromJson(json['slot']),
    );
  }
}
class SlotModel {
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int totalSeats;
  final int availableSeats;
  final bool isLocked;

  SlotModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalSeats,
    required this.availableSeats,
    required this.isLocked,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      totalSeats: json['total_seats'],
      availableSeats: json['available_seats'],
      isLocked: json['is_locked'],
    );
  }
}
