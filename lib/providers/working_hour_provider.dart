import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ================= MODEL =================

class WorkingHour {
  final int dayOfWeek;
  final String openTime; // HH:mm:ss
  final String closeTime; // HH:mm:ss
  final bool isClosed;

  WorkingHour({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  factory WorkingHour.fromJson(Map<String, dynamic> json) {
    return WorkingHour(
      dayOfWeek: json['day_of_week'],
      openTime: json['open_time'],
      closeTime: json['close_time'],
      isClosed: json['is_closed'],
    );
  }
}

/// ================= PROVIDER =================

class WorkingHoursProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<WorkingHour> hours = [];

  static const _base = "https://api.call4help.in/cyber/api/cyber/hours";

  /// 🔑 Token helper
  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('provider_auth_token');
    if (token == null || token.isEmpty) {
      throw Exception("Auth token missing");
    }
    return token;
  }

  /// ================= 1️⃣ GET LIST =================
  Future<void> fetchWorkingHours() async {
    _startLoading();

    try {
      final uri = Uri.parse("https://api.call4help.in/cyber/api/cyber/hours/working-hours");

      final response = await http.get(
        uri,
        headers: {"Authorization": "Bearer ${await _token()}"},
      );

      _log("GET HOURS", response);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        hours = (decoded['data'] as List)
            .map((e) => WorkingHour.fromJson(e))
            .toList();
      } else {
        error = "Failed to load working hours";
      }
    } catch (e) {
      error = e.toString();
    } finally {
      _stopLoading();
    }
  }

  Future<bool> setWorkingHours(List<Map<String, dynamic>> workingHours) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('provider_auth_token');
      if (token == null || token.isEmpty) {
        throw Exception("Auth token missing");
      }
      final uri = Uri.parse(
        "https://api.call4help.in/cyber/api/cyber/hours/set-working-hours",
      );
      print("🌐 SET WORKING HOURS URL: $uri");
      print("🧾 PAYLOAD: ${jsonEncode({"workingHours": workingHours})}");
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"workingHours": workingHours}),
      );
      print("📡 STATUS: ${response.statusCode}");
      print("📦 BODY: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          return true;
        } else {
          error = decoded['message'] ?? "Failed to set working hours";
        }
      } else {
        error = "Server error ${response.statusCode}";
      }
    } catch (e) {
      error = e.toString();
      print("🔥 ERROR: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }

  /// ================= 2️⃣ UPDATE ONE DAY (TIME) =================
  Future<bool> updateDay({
    required int day,
    required String openTime, // HH:mm
    required String closeTime, // HH:mm
    required bool isClosed,
  }) async {
    return _simpleRequest(
      method: "PUT",
      url: "$_base/working-hours/$day",
      body: {
        "day_of_week": day,
        "open_time": openTime,
        "close_time": closeTime,
        "is_closed": isClosed,
      },
    );
  }





  /// ================= 3️⃣ MARK OPEN =================
  Future<bool> openDay(int day) async {
    return _simpleRequest(
      method: "PATCH",
      url: "https://api.call4help.in/cyber/api/cyber/hours/working-hours/$day/open",
      body: {"day_of_week": day},
    );
  }

  /// ================= 4️⃣ MARK CLOSED =================
  Future<bool> closeDay(int day) async {
    return _simpleRequest(
      method: "PATCH",
      url: "https://api.call4help.in/cyber/api/cyber/hours/working-hours/$day/close",
      body: {"day_of_week": day},
    );
  }

  /// ================= 5️⃣ DELETE DAY =================
  Future<bool> deleteDay(int day) async {
    _startLoading();

    try {
      final token = await _token();

      final uri = Uri.parse(
        "https://api.call4help.in/cyber/api/cyber/hours/working-hours/$day",
      );

      print("======================================");
      print("🗑️ START DELETE WORKING DAY");
      print("======================================");
      print("🌐 DELETE URL: $uri");
      print("🔑 TOKEN EXISTS: ${token.isNotEmpty}");
      print("🧾 REQUEST BODY: { day_of_week: $day }");

      final request = http.Request("DELETE", uri);

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });

      print("📌 HEADERS:");
      request.headers.forEach((k, v) => print("   $k : $v"));

      // 🔑 Backend requires body even for DELETE
      request.body = jsonEncode({
        "day_of_week": day,
      });

      print("📤 SENDING DELETE REQUEST...");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("======================================");
      print("📡 DELETE RESPONSE RECEIVED");
      print("======================================");
      print("📡 STATUS CODE: ${response.statusCode}");
      print("📦 RAW BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ WORKING DAY DELETED SUCCESSFULLY");
        return true;
      } else {
        print("❌ DELETE FAILED");
        error = response.body;
        return false;
      }
    } catch (e, stack) {
      print("🔥 DELETE EXCEPTION OCCURRED");
      print("🔥 ERROR: $e");
      print("🧵 STACK TRACE:\n$stack");
      error = e.toString();
      return false;
    } finally {
      _stopLoading();
      print("🛑 DELETE FLOW ENDED");
      print("======================================");
    }
  }



  /// ================= INTERNAL HELPERS =================

  Future<bool> _simpleRequest({
    required String method,
    required String url,
    Map<String, dynamic>? body,
  }) async {
    _startLoading();

    try {
      final response = await http.Request(method, Uri.parse(url))
        ..headers.addAll({
          "Authorization": "Bearer ${await _token()}",
          "Content-Type": "application/json",
        })
        ..body = body != null ? jsonEncode(body) : "";

      final streamed = await response.send();
      final res = await http.Response.fromStream(streamed);

      _log(method, res);

      return res.statusCode == 200 ||
          res.statusCode == 201 ||
          res.statusCode == 204;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      _stopLoading();
    }
  }

  void _startLoading() {
    isLoading = true;
    error = null;
    notifyListeners();
  }

  void _stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  void _log(String tag, http.Response res) {
    debugPrint("🌐 $tag → ${res.request?.url}");
    debugPrint("📡 STATUS: ${res.statusCode}");
    debugPrint("📦 BODY: ${res.body}");
  }
}
