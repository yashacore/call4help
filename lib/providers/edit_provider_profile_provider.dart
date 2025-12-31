import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class EditProviderProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> updateProviderProfile({
    required String adharNo,
    // required String panNo,
    required bool isActive,
    required bool isRegistered,
    File? aadhaarPhoto,
    File? panPhoto,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('=== Starting API Call ===');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('provider_auth_token');

      debugPrint('Token exists: ${token != null && token.isNotEmpty}');

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found. Please login again.');
      }

      final url = 'https://api.call4help.in/api/provider/update-profile';
      debugPrint('API URL: $url');

      // Create multipart request
      var request = http.MultipartRequest('PUT', Uri.parse(url));

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      debugPrint('Headers added: ${request.headers}');

      // Add text fields
      request.fields['adhar_no'] = adharNo;
      // request.fields['pan_no'] = panNo;
      request.fields['isactive'] = isActive.toString();
      request.fields['isregistered'] = isRegistered.toString();

      debugPrint('Fields added: ${request.fields}');

      // Add aadhaar photo if provided
      if (aadhaarPhoto != null) {
        debugPrint('Checking Aadhaar photo...');
        bool exists = await aadhaarPhoto.exists();
        debugPrint('Aadhaar photo exists: $exists');

        if (exists) {
          try {
            String fileName = path.basename(aadhaarPhoto.path);
            String extension = path.extension(aadhaarPhoto.path).toLowerCase();
            debugPrint('Aadhaar file: $fileName, Extension: $extension');

            MediaType? contentType;
            if (extension == '.jpg' || extension == '.jpeg') {
              contentType = MediaType('image', 'jpeg');
            } else if (extension == '.png') {
              contentType = MediaType('image', 'png');
            } else if (extension == '.gif') {
              contentType = MediaType('image', 'gif');
            } else if (extension == '.webp') {
              contentType = MediaType('image', 'webp');
            } else {
              // Default to jpeg if unknown
              contentType = MediaType('image', 'jpeg');
            }

            debugPrint('Content type: $contentType');

            var aadhaarBytes = await aadhaarPhoto.readAsBytes();
            debugPrint('Aadhaar bytes length: ${aadhaarBytes.length}');

            var aadhaarFile = http.MultipartFile.fromBytes(
              'aadhaar_photo',
              aadhaarBytes,
              filename: fileName,
              contentType: contentType,
            );
            request.files.add(aadhaarFile);
            debugPrint('Aadhaar photo added to request');
          } catch (e) {
            debugPrint('Error reading aadhaar photo: $e');
            throw Exception('Failed to read Aadhaar photo: $e');
          }
        } else {
          debugPrint('Aadhaar photo file does not exist at path: ${aadhaarPhoto.path}');
        }
      } else {
        debugPrint('No Aadhaar photo provided');
      }

      // Add PAN photo if provided
      // if (panPhoto != null) {
      //   debugPrint('Checking PAN photo...');
      //   bool exists = await panPhoto.exists();
      //   debugPrint('PAN photo exists: $exists');
      //
      //   if (exists) {
      //     try {
      //       String fileName = path.basename(panPhoto.path);
      //       String extension = path.extension(panPhoto.path).toLowerCase();
      //       debugPrint('PAN file: $fileName, Extension: $extension');
      //
      //       MediaType? contentType;
      //       if (extension == '.jpg' || extension == '.jpeg') {
      //         contentType = MediaType('image', 'jpeg');
      //       } else if (extension == '.png') {
      //         contentType = MediaType('image', 'png');
      //       } else if (extension == '.gif') {
      //         contentType = MediaType('image', 'gif');
      //       } else if (extension == '.webp') {
      //         contentType = MediaType('image', 'webp');
      //       } else {
      //         // Default to jpeg if unknown
      //         contentType = MediaType('image', 'jpeg');
      //       }
      //
      //       debugPrint('Content type: $contentType');
      //
      //       var panBytes = await panPhoto.readAsBytes();
      //       debugPrint('PAN bytes length: ${panBytes.length}');
      //
      //       // var panFile = http.MultipartFile.fromBytes(
      //       //   'pan_photo',
      //       //   panBytes,
      //       //   filename: fileName,
      //       //   contentType: contentType,
      //       // );
      //       // request.files.add(panFile);
      //       debugPrint('PAN photo added to request');
      //     } catch (e) {
      //       debugPrint('Error reading pan photo: $e');
      //       throw Exception('Failed to read PAN photo: $e');
      //     }
      //   } else {
      //     debugPrint('PAN photo file does not exist at path: ${panPhoto.path}');
      //   }
      // } else {
      //   debugPrint('No PAN photo provided');
      // }

      debugPrint('Total files in request: ${request.files.length}');
      debugPrint('Sending request...');

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== API Response ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          debugPrint('Parsed JSON: $jsonData');

          if (jsonData['message'] != null) {
            debugPrint('Success: ${jsonData['message']}');
            _errorMessage = null;
            _isLoading = false;
            notifyListeners();
            return true;
          } else {
            throw Exception('Unexpected response format: missing message field');
          }
        } catch (e) {
          debugPrint('Error parsing response: $e');
          throw Exception('Failed to parse server response: $e');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 400) {
        try {
          final jsonData = json.decode(response.body);
          throw Exception(jsonData['message'] ?? 'Bad request. Please check your input.');
        } catch (e) {
          throw Exception('Bad request. Please check your input.');
        }
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        try {
          final jsonData = json.decode(response.body);
          throw Exception(jsonData['message'] ?? 'Failed to update profile (Status: ${response.statusCode})');
        } catch (e) {
          throw Exception('Failed to update profile (Status: ${response.statusCode})');
        }
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('=== Error ===');
      debugPrint('Error updating provider profile: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

class UpdateProfileResponse {
  final String message;
  final UpdateProfileResult result;

  UpdateProfileResponse({required this.message, required this.result});

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      message: json['message'] ?? '',
      result: UpdateProfileResult.fromJson(json['result'] ?? {}),
    );
  }
}

class UpdateProfileResult {
  final String? adharNo;
  final String? isActive;
  final String? isRegistered;
  // final String? panNo;

  UpdateProfileResult({
    this.adharNo,
    this.isActive,
    this.isRegistered,
    // this.panNo,
  });

  factory UpdateProfileResult.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResult(
      adharNo: json['adhar_no'],
      isActive: json['isactive'],
      isRegistered: json['isregistered'],
      // panNo: json['pan_no'],
    );
  }
}