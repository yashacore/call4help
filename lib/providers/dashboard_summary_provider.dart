import 'dart:convert';
import 'package:first_flutter/data/models/dashboard_summary_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardSummaryProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  DashboardSummary? summary;

  Future<void> fetchDashboardSummary() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('provider_auth_token');

      final response = await http.get(
        Uri.parse('https://api.call4help.in/cyber/api/provider/dashboard/summary'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        summary = DashboardSummary.fromJson(decoded['data']);
      } else {
        error = decoded['message'] ?? 'Something went wrong';
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
