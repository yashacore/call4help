import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/provider_slots_booking_provider.dart';
import 'package:first_flutter/screens/user_screens/cyber_cafe/my_booking_user.dart';
import 'package:first_flutter/screens/user_screens/razor_pay/razor_pay_service.dart';
import 'package:first_flutter/widgets/button_large.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookSlotScreen extends StatefulWidget {
  final String slotId;
  final String hourlyRate;
  final String subcategoryId;
  final String duration; // ✅ from API slot

  const BookSlotScreen({
    super.key,
    required this.slotId,
    required this.hourlyRate,
    required this.subcategoryId,
    required this.duration,
  });

  @override
  State<BookSlotScreen> createState() => _BookSlotScreenState();
}

class _BookSlotScreenState extends State<BookSlotScreen> {
  final _formKey = GlobalKey<FormState>();
  bool paymentCompleted = false;

  // ================= CONTROLLERS =================
  late final TextEditingController durationCtrl;
  final TextEditingController pcTypeCtrl = TextEditingController();

  // ================= PC TYPE STATE =================
  String selectedPcType = "gaming";
  final List<String> pcTypes = ["gaming", "office", "basic"];

  // ================= PRICE HELPERS =================
  String get baseAmount => widget.hourlyRate;
  String get extraCharges => "0";
  String get discountAmount => "0";

  double _toDouble(String v) => double.tryParse(v.trim()) ?? 0.0;

  String get totalAmount {
    final total =
        _toDouble(baseAmount) +
            _toDouble(extraCharges) -
            _toDouble(discountAmount);

    debugPrint(
      '🧮 [PriceCalc] base=$baseAmount extra=$extraCharges '
          'discount=$discountAmount => total=$total',
    );

    return total.toStringAsFixed(2);
  }

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    // ✅ duration comes from previous screen (API slot)
    durationCtrl = TextEditingController(text: widget.duration);

    // default pc type
    pcTypeCtrl.text = selectedPcType;
  }

  @override
  void dispose() {
    durationCtrl.dispose();
    pcTypeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderSlotBookingProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.appColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Book Slot"),
      ),

      bottomNavigationBar: provider.isLoading
          ? const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ButtonLarge(
          label: "Confirm Booking",
          onTap: () async {
            final razorAmount = int.tryParse(totalAmount) ?? int.parse(double.parse(totalAmount).toStringAsFixed(0));

            final provider = context.read<ProviderSlotBookingProvider>();

            debugPrint("🔵 [BookSlotScreen] Button Pressed");
            debugPrint("➡ slotId        : ${widget.slotId}");
            debugPrint("➡ hourlyRate    : ${widget.hourlyRate}");
            debugPrint("➡ subcategoryId : ${widget.subcategoryId}");
            debugPrint("➡ duration      : ${widget.duration}");

            // calculate dynamic amount
            final rate = int.tryParse(widget.hourlyRate) ?? 0;
            final duration = int.tryParse(widget.duration) ?? 1;

            debugPrint("🧮 [BookSlotScreen] Parsed Values");
            debugPrint("➡ parsed rate     : $rate");
            debugPrint("➡ parsed duration : $duration");

            final amountInPaise = rate * duration * 100;

            debugPrint("💰 [BookSlotScreen] Amount Calculation");
            debugPrint("➡ amountInPaise : $amountInPaise");

            final razorpay = RazorpayService();

            debugPrint("🟣 [BookSlotScreen] Initializing Razorpay");

            razorpay.init(
              onSuccess: (PaymentSuccessResponse res) async {
                debugPrint("✅ [Razorpay] PAYMENT SUCCESS CALLBACK");
                debugPrint("➡ paymentId : ${res.paymentId}");
                debugPrint("➡ orderId   : ${res.orderId}");
                debugPrint("➡ signature : ${res.signature}");
                debugPrint("➡ raw obj   : ${res.toString()}");

                debugPrint("🟢 [BookSlotScreen] Setting paymentCompleted = true");
                // ================= CAPTURE API AFTER PAYMENT SUCCESS =================

                final captureUrl = "https://api.call4help.in/cyber/api/payments/capture";
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('auth_token');

                final capturePayload = {
                  "order_id": widget.slotId,
                  "razorpay_payment_id": res.paymentId,
                  "amount": razorAmount
                };

                debugPrint("📡 [CaptureAPI] Calling after Razorpay success");
                debugPrint("➡ captureUrl     : $captureUrl");
                debugPrint("📦 [CaptureAPI] Payload: $capturePayload");

                final captureResponse = await http.post(
                  Uri.parse(captureUrl),
                  headers: {
                    "Content-Type": "application/json",
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode(capturePayload),
                );

                debugPrint("📡 [CaptureAPI] Status Code: ${captureResponse.statusCode}");
                debugPrint("📦 [CaptureAPI] Response Body: ${captureResponse.body}");


                setState(() {
                  paymentCompleted = true;
                });

                debugPrint("🟢 [BookSlotScreen] Triggering bookSlot API after payment");

                final success =
                await provider.bookSlot(

                  slotId: widget.slotId,
                  subcategoryId: widget.subcategoryId,
                  totalAmount: totalAmount,
                  baseAmount: baseAmount,
                  extraCharges: extraCharges,
                  discountAmount: discountAmount,
                  inputFields: {
                    "duration": durationCtrl.text,
                    "pc_type": pcTypeCtrl.text,
                  },
                  uploadedFiles: [
                    {
                      "file_name": "aadhar.pdf",
                      "file_url": "https://example.com/aadhar.pdf",
                    }
                  ],
                );

                debugPrint("📡 [BookSlotScreen] bookSlot API Result");
                debugPrint("➡ success : $success");
                debugPrint("➡ error   : ${provider.error}");

                if (!context.mounted) {
                  debugPrint("⚠️ [BookSlotScreen] context not mounted after API");
                  return;
                }

                if (success) {
                  debugPrint("🚀 [BookSlotScreen] Navigating to MyBookingUser");

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MyBookingUser()),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ Slot booked successfully after payment")),
                  );
                } else {
                  debugPrint("❌ [BookSlotScreen] Showing Booking Failed Snackbar");

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(provider.error ?? "Booking failed")),
                  );
                }
              },

              onError: (PaymentFailureResponse res) {
                debugPrint("❌ [Razorpay] PAYMENT ERROR CALLBACK");
                debugPrint("➡ code    : ${res.code}");
                debugPrint("➡ message : ${res.message}");
                debugPrint("➡ error   : ${res.error}");
                debugPrint("➡ raw obj : ${res.toString()}");
              },

              onWallet: (ExternalWalletResponse res) {
                debugPrint("🟡 [Razorpay] WALLET SELECTED CALLBACK");
                debugPrint("➡ walletName : ${res.walletName}");
                debugPrint("➡ raw obj    : ${res.toString()}");
              },
            );

            debugPrint("🟣 [BookSlotScreen] Opening Razorpay Checkout");

            // OPEN CHECKOUT WITH DYNAMIC DATA
            razorpay.openCheckout(
              amount: razorAmount,
              key: "rzp_test_RrrFFdWCi6TIZG",
              name: "Call4Help",
              description: "PC Slot Booking",
              contact: "123123123",
              email: "user@gmail.com",
            );

            debugPrint("🟣 [BookSlotScreen] Checkout Open Triggered");
          },


        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _durationField(),
              _pcTypeDropdown(),
              const SizedBox(height: 20),

              _priceTile("Base Amount", "₹$baseAmount"),
              _priceTile("Extra Charges", "₹$extraCharges"),
              _priceTile("Discount", "-₹$discountAmount"),
              _priceTile("Total Amount", "₹$totalAmount", highlight: true),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI WIDGETS =================

  Widget _durationField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: durationCtrl,
        readOnly: true, // 🔒 user cannot edit
        decoration: InputDecoration(
          labelText: "Duration",
          suffixIcon: const Icon(Icons.timer),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _pcTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedPcType,
        items: pcTypes.map((type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedPcType = value!;
            pcTypeCtrl.text = value;
          });
        },
        decoration: InputDecoration(
          labelText: "PC Type",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _priceTile(String label, String value, {bool highlight = false}) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: highlight ? Colors.green : Colors.black,
        ),
      ),
    );
  }

}
