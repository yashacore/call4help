import 'dart:convert';
import 'package:first_flutter/data/models/user_notification_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProviderUser extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<UserNotification> notifications = [];

  Future<void> fetchNotifications() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('https://api.call4help.in/cyber-service/notifications/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        notifications = (decoded['data'] as List)
            .map((e) => UserNotification.fromJson(e))
            .toList();
      } else {
        error = 'Failed to load notifications';
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('https://api.call4help.in/cyber-service/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        final index =
        notifications.indexWhere((n) => n.id == notificationId);

        if (index != -1) {
          notifications[index] = notifications[index].copyWith(isRead: true);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('markAsRead error: $e');
      return false;
    }
  }
  Future<void> markSelectedAsRead(List<int> ids) async {
    for (final id in ids) {
      await markAsRead(id);
    }
  }
  Future<void> markAllAsRead() async {
    for (final n in notifications.where((n) => !n.isRead)) {
      await markAsRead(n.id);
    }
  }

}
