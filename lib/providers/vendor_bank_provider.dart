import 'dart:convert';
import 'package:first_flutter/data/models/provider_bank_details.dart';
import 'package:first_flutter/providers/provider_bank_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VendorBankProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  bool isSuccess = false;

  Future<void> addBankDetails(ProviderBankModel model) async {

    isLoading = true;
    error = null;
    isSuccess = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('provider_auth_token');

      final url =
          'https://api.call4help.in/cyber-service/api/provider/bank';

      final body = jsonEncode(model.toJson());

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );


      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        isSuccess = true;
      } else {
        error = decoded['message'] ?? 'Failed to add bank details';
      }
    } catch (e, stack) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ProviderBankDetails? bankDetails;

  Future<void> fetchBankDetails() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('provider_auth_token');

      final response = await http.get(
        Uri.parse('https://api.call4help.in/cyber-service/api/provider/bank'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        bankDetails =
            ProviderBankDetails.fromJson(decoded['data']);
      } else {
        error = 'Failed to fetch bank details';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


}
