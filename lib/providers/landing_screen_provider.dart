import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ================= PROVIDER =================

class ProviderCafeProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  ProviderCafeModel? cafe;

  Future<void> fetchMyCafe() async {
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
        "https://api.call4help.in/cyber/api/cyber/provider/cafe/me",
      );

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("📡 STATUS: ${response.statusCode}");
      debugPrint("📦 BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        /// ✅ VERY IMPORTANT SAFETY CHECK
        if (decoded['success'] == true &&
            decoded['cafe'] != null &&
            decoded['cafe'] is Map<String, dynamic>) {
          cafe = ProviderCafeModel.fromJson(decoded['cafe']);
        } else {
          cafe = null;
          error = decoded['message'] ?? "Cafe not found";
        }
      } else {
        error = "Server error ${response.statusCode}";
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

/// ================= MODEL =================

class ProviderCafeModel {
  final String id;
  final String shopName;
  final String ownerName;
  final String phone;
  final String email;
  final String gstNumber;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pincode;
  final int totalComputers;
  final int availableComputers;
  final String verificationStatus;
  final String openingTime;
  final String closingTime;
  final bool isActive;
  final String latitude;
  final String longitude;

  ProviderCafeModel({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.email,
    required this.gstNumber,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.totalComputers,
    required this.availableComputers,
    required this.verificationStatus,
    required this.openingTime,
    required this.closingTime,
    required this.isActive,
    required this.latitude,
    required this.longitude,
  });

  factory ProviderCafeModel.fromJson(Map<String, dynamic> json) {
    return ProviderCafeModel(
      id: json['id']?.toString() ?? "",
      shopName: json['shop_name']?.toString().replaceAll('"', '') ?? "",
      ownerName: json['owner_name']?.toString().replaceAll('"', '') ?? "",
      phone: json['phone']?.toString() ?? "",
      email: json['email']?.toString() ?? "",
      gstNumber: json['gst_number']?.toString() ?? "",
      addressLine1: json['address_line1']?.toString() ?? "",
      addressLine2: json['address_line2']?.toString() ?? "",
      city: json['city']?.toString() ?? "",
      state: json['state']?.toString() ?? "",
      pincode: json['pincode']?.toString() ?? "",
      totalComputers:
      int.tryParse(json['total_computers']?.toString() ?? "0") ?? 0,
      availableComputers:
      int.tryParse(json['available_computers']?.toString() ?? "0") ?? 0,
      verificationStatus:
      json['verification_status']?.toString() ?? "pending",
      openingTime: json['opening_time']?.toString() ?? "--",
      closingTime: json['closing_time']?.toString() ?? "--",
      isActive: json['is_active'] == true,
      latitude: json['latitude']?.toString() ?? "",
      longitude: json['longitude']?.toString() ?? "",
    );
  }
}
