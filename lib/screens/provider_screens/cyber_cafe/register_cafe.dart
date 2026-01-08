import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/register_cafe_provider.dart';
import 'package:first_flutter/widgets/button_large.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class CyberCafeRegisterScreen extends StatefulWidget {
  const CyberCafeRegisterScreen({super.key});

  @override
  State<CyberCafeRegisterScreen> createState() =>
      _CyberCafeRegisterScreenState();
}

class _CyberCafeRegisterScreenState extends State<CyberCafeRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final shopNameCtrl = TextEditingController();
  final ownerNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();
  final address1Ctrl = TextEditingController();
  final address2Ctrl = TextEditingController();
  final totalComputerCtrl = TextEditingController();
  final openingCtrl = TextEditingController();
  final closingCtrl = TextEditingController();
  final gstCtrl = TextEditingController();

  Future<void> pickTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      controller.text =
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldGray,
      appBar: AppBar(
        title: const Text("Register Cyber Cafe"),
        backgroundColor: ColorConstant.appColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(key: _formKey, child: _formCard()),
            ),
          ),
          _submitButton(),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _input("Shop Name", Icons.store, shopNameCtrl),
          _input("Owner Name", Icons.person, ownerNameCtrl),
          _input(
            "Phone",
            Icons.phone,
            phoneCtrl,
            keyboard: TextInputType.phone,
          ),
          _input(
            "Email",
            Icons.email,
            emailCtrl,
            keyboard: TextInputType.emailAddress,
          ),
          _input("City", Icons.location_city, cityCtrl),
          _input("State", Icons.map, stateCtrl),
          _input(
            "Pincode",
            Icons.pin,
            pincodeCtrl,
            keyboard: TextInputType.number,
          ),
          _input("Address Line 1", Icons.home, address1Ctrl),
          _input("Address Line 2", Icons.home_work, address2Ctrl),
          _input(
            "Total Computers",
            Icons.computer,
            totalComputerCtrl,
            keyboard: TextInputType.number,
          ),
          _timeInput("Opening Time", openingCtrl),
          _timeInput("Closing Time", closingCtrl),
          _input("GST Number", Icons.receipt_long, gstCtrl),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _input(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) => v == null || v.isEmpty ? "$label required" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ColorConstant.appColor),
          filled: true,
          fillColor: ColorConstant.scaffoldGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _timeInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => pickTime(controller),
        validator: (v) => v == null || v.isEmpty ? "$label required" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(
            Icons.access_time,
            color: ColorConstant.appColor,
          ),
          filled: true,
          fillColor: ColorConstant.scaffoldGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }


  Widget _submitButton() {
    return Consumer<RegisterCafeProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: ButtonLarge(
            label: "Register Cafe",
            onTap: provider.isLoading
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) return;

                    try {
                      // 📍 Get live location
                      final position = await _getCurrentLocation();

                      final success = await provider.registerCafe(
                        shopName: shopNameCtrl.text,
                        ownerName: ownerNameCtrl.text,
                        phone: phoneCtrl.text,
                        email: emailCtrl.text,
                        city: cityCtrl.text,
                        state: stateCtrl.text,
                        pincode: pincodeCtrl.text,
                        addressLine1: address1Ctrl.text,
                        addressLine2: address2Ctrl.text,
                        latitude: position.latitude.toString(),
                        longitude: position.longitude.toString(),
                        totalComputers: int.parse(totalComputerCtrl.text),
                        openingTime: openingCtrl.text,
                        closingTime: closingCtrl.text,
                        gstNumber: gstCtrl.text,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? "✅ Cafe registered successfully"
                                : "❌ Registration failed",
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("📍 Location error: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
          ),
        );
      },
    );
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
