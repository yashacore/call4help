import 'dart:convert';
import 'package:first_flutter/data/models/vendor_notification_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VendorNotificationProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<VendorNotification> notifications = [];

  Future<void> fetchVendorNotifications() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('provider_auth_token');

      final response = await http.get(
        Uri.parse(
          'https://api.call4help.in/cyber/notifications/provider',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        notifications = (decoded['data'] as List)
            .map((e) => VendorNotification.fromJson(e))
            .toList();
      } else {
        error = 'Failed to load notifications';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
