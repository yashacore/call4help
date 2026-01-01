import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterCafeProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;


  Future<bool> registerCafe({
    required String shopName,
    required String ownerName,
    required String phone,
    required String email,
    required String city,
    required String state,
    required String pincode,
    required String addressLine1,
    required String addressLine2,
    required String latitude,
    required String longitude,
    required int totalComputers,
    required String openingTime, // HH:mm
    required String closingTime, // HH:mm
    required String gstNumber,
  }) async {
    isLoading = true;
    notifyListeners();

    print("======================================");
    print("🚀 STARTING CAFE REGISTRATION");
    print("======================================");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('provider_auth_token');

      if (token == null || token.isEmpty) {
        print("❌ Auth token missing");
        return false;
      }

      final uri = Uri.parse(
        "https://api.call4help.in/cyber/api/cyber/provider/cafe/register",
      );

      print("🌐 API URL: $uri");

      final request = http.MultipartRequest("POST", uri);
      request.headers["Authorization"] = "Bearer $token";

      final fields = {
        "shop_name": shopName,
        "owner_name": ownerName,
        "phone": phone,
        "email": email,
        "city": city,
        "state": state,
        "pincode": pincode,
        "address_line1": addressLine1,
        "address_line2": addressLine2,
        "latitude": latitude,
        "longitude": longitude,
        "total_computers": totalComputers.toString(),
        "opening_time": openingTime,
        "closing_time": closingTime,
        "gst_number": gstNumber,
      };

      request.fields.addAll(fields);

      print("🧾 REQUEST FIELDS:");
      fields.forEach((k, v) => print("   $k : $v"));

      // print("📎 Attaching shop image: $shopImagePath");
      // request.files.add(
      //   await http.MultipartFile.fromPath(
      //     "shop_images",
      //     shopImagePath,
      //   ),
      // );
      //
      // print("📎 Attaching document: $documentPath");
      // request.files.add(
      //   await http.MultipartFile.fromPath(
      //     "documents",
      //     documentPath,
      //   ),
      // );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("📡 STATUS: ${response.statusCode}");
      print("📦 BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print("✅ Cafe registered successfully");
          return true;
        }
      }
    } catch (e, stack) {
      print("🔥 ERROR: $e");
      print(stack);
    } finally {
      isLoading = false;
      notifyListeners();
      print("🛑 REGISTRATION END");
    }

    return false;
  }




  Future<bool> updateCafe({
    required String cafeId,

    required String shopName,
    required String ownerName,
    required String phone,
    required String email,
    required String city,
    required String state,
    required String pincode,
    required String addressLine1,
    required String addressLine2,
    required String latitude,
    required String longitude,
    required int totalComputers,
    required String openingTime, // HH:mm
    required String closingTime, // HH:mm
    required String gstNumber,

    List<File>? shopImages,
    List<File>? documents,
  }) async {
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
        "https://api.call4help.in/cyber/api/cyber/provider/cafe/$cafeId",
      );

      print("======================================");
      print("🟦 UPDATE CAFE");
      print("🌐 URL: $uri");

      final request = http.MultipartRequest("PATCH", uri);

      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      /// 🧾 TEXT FIELDS
      final fields = {
        "shop_name": shopName,
        "owner_name": ownerName,
        "phone": phone,
        "email": email,
        "city": city,
        "state": state,
        "pincode": pincode,
        "address_line1": addressLine1,
        "address_line2": addressLine2,
        "latitude": latitude,
        "longitude": longitude,
        "total_computers": totalComputers.toString(),
        "opening_time": openingTime,
        "closing_time": closingTime,
        "gst_number": gstNumber,
      };

      request.fields.addAll(fields);

      print("🧾 FIELDS:");
      fields.forEach((k, v) => print("   $k : $v"));

      /// 🖼 SHOP IMAGES (MULTIPLE)
      if (shopImages != null) {
        for (final file in shopImages) {
          print("📎 SHOP IMAGE: ${file.path}");
          request.files.add(
            await http.MultipartFile.fromPath(
              "shop_images",
              file.path,
            ),
          );
        }
      }

      /// 📄 DOCUMENTS (MULTIPLE)
      if (documents != null) {
        for (final file in documents) {
          print("📎 DOCUMENT: ${file.path}");
          request.files.add(
            await http.MultipartFile.fromPath(
              "documents",
              file.path,
            ),
          );
        }
      }

      print("📤 SENDING UPDATE REQUEST...");

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print("📡 STATUS: ${response.statusCode}");
      print("📦 BODY: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      }

      error = "Failed to update cafe";
      return false;
    } catch (e, stack) {
      print("🔥 UPDATE CAFE ERROR: $e");
      print(stack);
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
      print("🛑 UPDATE CAFE FLOW ENDED");
      print("======================================");
    }
  }
}
