import 'dart:convert';
import 'package:first_flutter/config/baseControllers/APis.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StartWorkProvider extends ChangeNotifier {
  bool _isProcessing = false;
  String? _errorMessage;
  bool _isSuccess = false;

  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  /// Start work with OTP
  Future<bool> startWork(String serviceId, String otp) async {
    _isProcessing = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final providerToken = prefs.getString('provider_auth_token');

      if (providerToken == null) {
        _errorMessage = 'Authentication token not found';
        _isProcessing = false;
        notifyListeners();
        return false;
      }

      final response = await http.post(
        Uri.parse('$base_url/bid/api/service/start-service'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $providerToken',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'otp': otp,
        }),
      );

      debugPrint('Start Work Response - Status: ${response.statusCode}');
      debugPrint('Start Work Response - Body: ${response.body}');

      if (response.statusCode == 200) {
        // ✅ success case
        final responseData = jsonDecode(response.body);
        _isSuccess = true;
        _errorMessage = null;
        _isProcessing = false;
        notifyListeners();
        return true;
      } else {
        // ❌ error case
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to start work';
        _isProcessing = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isProcessing = false;
      _errorMessage = 'Error starting work: $e';
      notifyListeners();
      return false;
    }
  }

  /// End work with OTP
  Future<bool> endWork(String serviceId, String otp) async {
    _isProcessing = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final providerToken = prefs.getString('provider_auth_token');

      if (providerToken == null) {
        _errorMessage = 'Authentication token not found';
        _isProcessing = false;
        notifyListeners();
        return false;
      }

      final response = await http.post(
        Uri.parse('$base_url/bid/api/service/end-service'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $providerToken',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'otp': otp,
        }),
      );

      debugPrint('End Work Response - Status: ${response.statusCode}');
      debugPrint('End Work Response - Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _isSuccess = true;
        _errorMessage = null;
        _isProcessing = false;
        notifyListeners();
        return true;
      } else {
        final message = responseData['message'];

        if (message is String) {
          _errorMessage = message;
        } else if (message is Map) {
          _errorMessage = message.values.join(', ');
        } else {
          _errorMessage = 'Failed to end work';
        }

        _isProcessing = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isProcessing = false;
      _errorMessage = 'Error ending work: $e';
      notifyListeners();
      return false;
    }
  }

  /// Reset provider state
  void reset() {
    _isProcessing = false;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}