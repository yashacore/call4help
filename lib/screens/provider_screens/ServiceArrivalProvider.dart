import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../baseControllers/APis.dart';

class ServiceArrivalProvider extends ChangeNotifier {

  // Timer state
  int _remainingSeconds = 600;
  bool _isTimerActive = false;
  bool _hasArrived = false;
  bool _canStartWork = false;
  DateTime? _arrivalTime;
  String? _currentServiceId;

  // Loading states
  bool _isProcessingArrival = false;
  String? _errorMessage;

  // Getters
  int get remainingSeconds => _remainingSeconds;

  bool get isTimerActive => _isTimerActive;

  bool get hasArrived => _hasArrived;

  bool get canStartWork => _canStartWork;

  bool get isProcessingArrival => _isProcessingArrival;

  String? get errorMessage => _errorMessage;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  ServiceArrivalProvider() {
    _initializeTimer();
  }

  // Initialize timer state from SharedPreferences
  Future<void> _initializeTimer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serviceId = prefs.getString('timer_service_id');

      if (serviceId != null && serviceId.isNotEmpty) {
        _currentServiceId = serviceId;
        final arrivalTimeStr = prefs.getString('arrival_time_$serviceId');

        if (arrivalTimeStr != null) {
          _arrivalTime = DateTime.parse(arrivalTimeStr);
          _hasArrived = true;

          // Calculate remaining time
          final elapsed = DateTime.now().difference(_arrivalTime!).inSeconds;
          _remainingSeconds = 600 - elapsed; // 10 minutes = 600 seconds

          if (_remainingSeconds <= 0) {
            // Timer completed
            _remainingSeconds = 0;
            _isTimerActive = false;
            _canStartWork = true;
          } else {
            // Timer still running
            _isTimerActive = true;
            _canStartWork = false;
            _startTimerCountdown();
          }

          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error initializing timer: $e');
    }
  }

  // Load timer state for specific service
  Future<void> loadTimerState(String serviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentServiceId = serviceId;

      final arrivalTimeStr = prefs.getString('arrival_time_$serviceId');
      final hasArrivedFlag = prefs.getBool('has_arrived_$serviceId') ?? false;

      if (arrivalTimeStr != null && hasArrivedFlag) {
        _arrivalTime = DateTime.parse(arrivalTimeStr);
        _hasArrived = true;

        // Calculate remaining time
        final elapsed = DateTime.now().difference(_arrivalTime!).inSeconds;
        _remainingSeconds = 600 - elapsed;

        if (_remainingSeconds <= 0) {
          _remainingSeconds = 0;
          _isTimerActive = false;
          _canStartWork = true;
        } else {
          _isTimerActive = true;
          _canStartWork = false;
          _startTimerCountdown();
        }

        notifyListeners();
      } else {
        // Reset state for new service
        _resetTimerState();
      }
    } catch (e) {
      debugPrint('Error loading timer state: $e');
      _resetTimerState();
    }
  }

  // Confirm provider arrival
  Future<bool> confirmProviderArrival(String serviceId) async {
    if (_isProcessingArrival) return false;

    _isProcessingArrival = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final providerToken = prefs.getString('provider_auth_token');

      if (providerToken == null) {
        _errorMessage = 'Provider authentication token not found';
        _isProcessingArrival = false;
        notifyListeners();
        return false;
      }

      final response = await http.post(
        Uri.parse('$base_url/bid/api/service/provider-arrived'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $providerToken',
        },
        body: jsonEncode({'service_id': serviceId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save arrival time and state
        _currentServiceId = serviceId;
        _arrivalTime = DateTime.now();
        _hasArrived = true;
        _isTimerActive = true;
        _canStartWork = false;
        _remainingSeconds = 600; // Reset to 10 minutes

        // Persist state
        await prefs.setString('timer_service_id', serviceId);
        await prefs.setString(
          'arrival_time_$serviceId',
          _arrivalTime!.toIso8601String(),
        );
        await prefs.setBool('has_arrived_$serviceId', true);

        // Start countdown
        _startTimerCountdown();

        _isProcessingArrival = false;
        notifyListeners();
        return true;
      } else {
        final responseBody = jsonDecode(response.body);
        _errorMessage = responseBody['message'] ?? 'Failed to confirm arrival';
        _isProcessingArrival = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error confirming arrival: $e';
      _isProcessingArrival = false;
      notifyListeners();
      return false;
    }
  }

  // Start timer countdown
  void _startTimerCountdown() {
    // Cancel any existing timer
    Future.delayed(const Duration(seconds: 1), () {
      if (_isTimerActive && _remainingSeconds > 0) {
        _remainingSeconds--;

        if (_remainingSeconds <= 0) {
          _remainingSeconds = 0;
          _isTimerActive = false;
          _canStartWork = true;
        }

        notifyListeners();

        if (_isTimerActive) {
          _startTimerCountdown();
        }
      }
    });
  }

  // Clear timer state (call when work starts or service completes)
  Future<void> clearTimerState(String serviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('arrival_time_$serviceId');
      await prefs.remove('has_arrived_$serviceId');

      if (_currentServiceId == serviceId) {
        await prefs.remove('timer_service_id');
        _resetTimerState();
      }
    } catch (e) {
      debugPrint('Error clearing timer state: $e');
    }
  }

  // Reset timer state
  void _resetTimerState() {
    _remainingSeconds = 600;
    _isTimerActive = false;
    _hasArrived = false;
    _canStartWork = false;
    _arrivalTime = null;
    _currentServiceId = null;
    notifyListeners();
  }

  // Check if timer is active for a specific service
  bool isTimerActiveForService(String serviceId) {
    return _currentServiceId == serviceId && _isTimerActive;
  }

  // Check if can start work for a specific service
  bool canStartWorkForService(String serviceId) {
    return _currentServiceId == serviceId && _canStartWork;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
