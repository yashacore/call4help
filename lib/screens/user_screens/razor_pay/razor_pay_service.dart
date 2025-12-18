import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay _razorpay;

  void init({
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onError,
    required void Function(ExternalWalletResponse) onWallet,
  }) {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse res) {
      debugPrint("✅ PAYMENT SUCCESS CALLBACK");
      debugPrint("paymentId : ${res.paymentId}");
      debugPrint("orderId   : ${res.orderId}");
      debugPrint("signature : ${res.signature}");
      onSuccess(res);
    });

    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse res) {
      debugPrint("❌ PAYMENT ERROR CALLBACK");
      debugPrint("code    : ${res.code}");
      debugPrint("message : ${res.message}");
      debugPrint("error   : ${res.error}");
      onError(res);
    });

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
          (ExternalWalletResponse res) {
        debugPrint("🟡 EXTERNAL WALLET SELECTED");
        debugPrint("wallet : ${res.walletName}");
        onWallet(res);
      },
    );
  }

  void openCheckout({
    required int amount, // ₹ amount
    required String key,
    required String name,
    required String description,
    required String contact,
    required String email,
    String? orderId, // OPTIONAL
  }) {
    final options = {
      'key': key,
      'amount': amount * 100, // convert to paise
      'name': name,
      'description': description,
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'theme': {
        'color': '#F37254',
      },
      if (orderId != null) 'order_id': orderId,
    };

    debugPrint("🧾 Razorpay Checkout Options:");
    debugPrint(options.toString());

    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}
