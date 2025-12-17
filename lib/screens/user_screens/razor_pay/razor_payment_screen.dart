import 'package:first_flutter/screens/user_screens/razor_pay/razor_pay_service.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final RazorpayService _razorpayService = RazorpayService();

  @override
  void initState() {
    super.initState();

    _razorpayService.init(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onWallet: _handleExternalWallet,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Payment Success: ${response.paymentId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
  }

  void _payNow() {
    _razorpayService.openCheckout(
      amount: 500,
      key: "rzp_test_RrrFFdWCi6TIZG",
      name: "My App",
      description: "Test Payment",
      contact: "9999999999",
      email: "test@email.com",
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Razorpay Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: _payNow,
          child: const Text("Pay ₹500"),
        ),
      ),
    );
  }
}
