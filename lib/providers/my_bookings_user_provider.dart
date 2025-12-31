import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyBookingsUserProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  /// ✅ Correct model type
  List<BookingItem> bookings = [];

  Map<String, OrderDetails> orderDetailsMap = {};
  Set<String> loadingOrders = {};

  Future<void> fetchOrderDetails(String orderId) async {
    if (orderDetailsMap.containsKey(orderId)) return;

    debugPrint("🔍 Fetching details for order: $orderId");
    loadingOrders.add(orderId);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url =
          'https://api.call4help.in/cyber/api/user/dashboard/bookings/$orderId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        orderDetailsMap[orderId] =
            OrderDetails.fromJson(decoded['data']);
      }
    } catch (e) {
      debugPrint("❌ Order details error: $e");
    }

    loadingOrders.remove(orderId);
    notifyListeners();
  }


  Future<bool> cancelBooking({
    required String orderId,
  }) async {
    debugPrint("🚀 ===== cancelBooking START =====");
    debugPrint("🧾 Order ID: $orderId");

    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      debugPrint("🔑 Token exists: ${token != null}");

      if (token == null) {
        throw Exception("Auth token missing");
      }

      const url =
          'https://api.call4help.in/cyber/provider/slots/cancel';

      debugPrint("🌐 API URL: $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "order_id": orderId,
        }),
      );

      debugPrint("📥 Status Code: ${response.statusCode}");
      debugPrint("📦 Response Body: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        debugPrint("✅ Booking cancelled successfully");

        /// 🔄 Refresh bookings
        await fetchMyBookings();

        return true;
      } else {
        error = decoded['message'] ?? "Cancel failed";
        debugPrint("❌ Cancel failed: $error");
      }
    } catch (e, stack) {
      error = e.toString();
      debugPrint("🔥 Cancel error: $e");
      debugPrint("📍 Stacktrace:\n$stack");
    }

    isLoading = false;
    notifyListeners();
    debugPrint("🏁 ===== cancelBooking END =====");
    return false;
  }


  Future<void> fetchMyBookings() async {
    debugPrint("🚀 ===== fetchMyBookings START =====");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      /// ⚠️ Use the SAME token key everywhere
      final token = prefs.getString('auth_token');
      debugPrint("🔑 Token exists: ${token != null}");

      if (token == null) {
        throw Exception("Auth token missing");
      }

      const url =
          'https://api.call4help.in/cyber/provider/slots/my-bookings';

      debugPrint("🌐 API URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("📥 Status Code: ${response.statusCode}");
      debugPrint("📦 Response Body: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        final List list = decoded['data'] ?? [];

        bookings = list
            .map((e) => BookingItem.fromJson(e))
            .toList();

        debugPrint("✅ My Bookings Loaded: ${bookings.length}");
      } else {
        error = decoded['message'] ?? "Failed to load bookings";
      }
    } catch (e, stack) {
      error = e.toString();
      debugPrint("🔥 fetchMyBookings ERROR: $e");
      debugPrint("📍 STACKTRACE:\n$stack");
    }

    isLoading = false;
    notifyListeners();
    debugPrint("🏁 ===== fetchMyBookings END =====");
  }
}

class MyBookingsResponse {
  final bool success;
  final List<BookingItem> data;

  MyBookingsResponse({
    required this.success,
    required this.data,
  });

  factory MyBookingsResponse.fromJson(Map<String, dynamic> json) {
    return MyBookingsResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => BookingItem.fromJson(e))
          .toList(),
    );
  }
}
class BookingItem {
  final String id;
  final String cyberCafeId;
  final String slotId;
  final String orderType;

  final dynamic inputFields;
  final dynamic uploadedFiles;

  final String baseAmount;
  final String extraCharges;
  final String discountAmount;
  final String totalAmount;

  final String paymentStatus;
  final String status;

  final String? providerNotes;
  final String? userNotes;

  final String createdAt;
  final String updatedAt;

  final int? userId;
  final int? subcategoryId;
  final int? providerId;

  final String? paymentMethod;
  final String? paymentReference;
  final String? paymentGateway;
  final String? gatewayOrderId;
  final String? gatewayPaymentId;
  final dynamic paymentResponse;

  final String? commissionPercent;
  final String? commissionAmount;
  final String? providerAmount;

  final String? acceptedAt;
  final String? completedAt;
  final String? cancelledAt;
  final String? cancelledBy;
  final String? cancellationReason;

  final SlotModel? slot;

  BookingItem({
    required this.id,
    required this.cyberCafeId,
    required this.slotId,
    required this.orderType,
    this.inputFields,
    this.uploadedFiles,
    required this.baseAmount,
    required this.extraCharges,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentStatus,
    required this.status,
    this.providerNotes,
    this.userNotes,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.subcategoryId,
    this.providerId,
    this.paymentMethod,
    this.paymentReference,
    this.paymentGateway,
    this.gatewayOrderId,
    this.gatewayPaymentId,
    this.paymentResponse,
    this.commissionPercent,
    this.commissionAmount,
    this.providerAmount,
    this.acceptedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.slot,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      id: json['id'] ?? '',
      cyberCafeId: json['cyber_cafe_id'] ?? '',
      slotId: json['slot_id'] ?? '',
      orderType: json['order_type'] ?? '',

      inputFields: json['input_fields'],
      uploadedFiles: json['uploaded_files'],

      baseAmount: json['base_amount']?.toString() ?? '0.00',
      extraCharges: json['extra_charges']?.toString() ?? '0.00',
      discountAmount: json['discount_amount']?.toString() ?? '0.00',
      totalAmount: json['total_amount']?.toString() ?? '0.00',

      paymentStatus: json['payment_status'] ?? '',
      status: json['status'] ?? '',

      providerNotes: json['provider_notes'],
      userNotes: json['user_notes'],

      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',

      userId: json['user_id'],
      subcategoryId: json['subcategory_id'],
      providerId: json['provider_id'],

      paymentMethod: json['payment_method'],
      paymentReference: json['payment_reference'],
      paymentGateway: json['payment_gateway'],
      gatewayOrderId: json['gateway_order_id'],
      gatewayPaymentId: json['gateway_payment_id'],
      paymentResponse: json['payment_response'],

      commissionPercent: json['commission_percent']?.toString(),
      commissionAmount: json['commission_amount']?.toString(),
      providerAmount: json['provider_amount']?.toString(),

      acceptedAt: json['accepted_at'],
      completedAt: json['completed_at'],
      cancelledAt: json['cancelled_at'],
      cancelledBy: json['cancelled_by'],
      cancellationReason: json['cancellation_reason'],

      slot: json['slot'] != null
          ? SlotModel.fromJson(json['slot'])
          : null,
    );
  }
}
class SlotModel {
  final String id;
  final String cyberCafeId;
  final String? date;
  final String startTime;
  final String endTime;
  final int totalSeats;
  final int availableSeats;
  final bool isLocked;
  final String createdAt;
  final String updatedAt;

  SlotModel({
    required this.id,
    required this.cyberCafeId,
    this.date,
    required this.startTime,
    required this.endTime,
    required this.totalSeats,
    required this.availableSeats,
    required this.isLocked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'] ?? '',
      cyberCafeId: json['cyber_cafe_id'] ?? '',
      date: json['date'],
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      totalSeats: json['total_seats'] ?? 0,
      availableSeats: json['available_seats'] ?? 0,
      isLocked: json['is_locked'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
class OrderDetails {
  final String id;
  final String status;
  final String totalAmount;
  final String paymentStatus;
  final String createdAt;
  final SlotModel? slot;
  final CafeModel? cafe;

  OrderDetails({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.paymentStatus,
    required this.createdAt,
    this.slot,
    this.cafe,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      paymentStatus: json['payment_status'] ?? '',
      createdAt: json['created_at'] ?? '',
      slot: json['slot'] != null
          ? SlotModel.fromJson(json['slot'])
          : null,
      cafe: json['cafe'] != null
          ? CafeModel.fromJson(json['cafe'])
          : null,
    );
  }
}

class CafeModel {
  final String shopName;
  final String address;
  final String phone;

  CafeModel({
    required this.shopName,
    required this.address,
    required this.phone,
  });

  factory CafeModel.fromJson(Map<String, dynamic> json) {
    return CafeModel(
      shopName: json['shop_name'] ?? '',
      address: json['address_line1'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
