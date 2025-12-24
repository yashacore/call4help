import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/register_cafe_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CyberCafeRegisterScreen extends StatefulWidget {
  const CyberCafeRegisterScreen({super.key});

  @override
  State<CyberCafeRegisterScreen> createState() =>
      _CyberCafeRegisterScreenState();
}

class _CyberCafeRegisterScreenState
    extends State<CyberCafeRegisterScreen> {
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

  String? documentPath;

  Future<void> pickTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      controller.text = time.format(context);
    }
  }

  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        documentPath = result.files.single.path!;
      });
    }
  }

  @override
  void dispose() {
    shopNameCtrl.dispose();
    ownerNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    pincodeCtrl.dispose();
    address1Ctrl.dispose();
    address2Ctrl.dispose();
    totalComputerCtrl.dispose();
    openingCtrl.dispose();
    closingCtrl.dispose();
    gstCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text("Register Cafe"),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: ColorConstant.appColor,
      ),
      backgroundColor: ColorConstant.scaffoldGray,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: _formCard(),
              ),
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
        color: ColorConstant.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _input("Shop Name", Icons.store, shopNameCtrl),
          _input("Owner Name", Icons.person, ownerNameCtrl),
          _input("Phone", Icons.phone, phoneCtrl,
              keyboard: TextInputType.phone),
          _input("Email", Icons.email, emailCtrl,
              keyboard: TextInputType.emailAddress),
          _input("City", Icons.location_city, cityCtrl),
          _input("State", Icons.map, stateCtrl),
          _input("Pincode", Icons.pin, pincodeCtrl,
              keyboard: TextInputType.number),
          _input("Address Line 1", Icons.home, address1Ctrl),
          _input("Address Line 2", Icons.home_work, address2Ctrl),
          _input("Total Computers", Icons.computer, totalComputerCtrl,
              keyboard: TextInputType.number),
          _timeInput("Opening Time", openingCtrl),
          _timeInput("Closing Time", closingCtrl),
          _input("GST Number", Icons.receipt_long, gstCtrl),
          _uploadButton(),
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
        validator: (v) =>
        v == null || v.isEmpty ? "$label required" : null,
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
        validator: (v) =>
        v == null || v.isEmpty ? "$label required" : null,
        onTap: () => pickTime(controller),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
          const Icon(Icons.access_time, color: ColorConstant.appColor),
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

  Widget _uploadButton() {
    return GestureDetector(
      onTap: pickDocument,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ColorConstant.appColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.upload_file, color: ColorConstant.appColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                documentPath != null
                    ? File(documentPath!).path.split('/').last
                    : "Upload Documents",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Consumer<RegisterCafeProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: ColorConstant.buttonBg,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
            ),
            onPressed: provider.isLoading
                ? null
                : () async {
              if (!_formKey.currentState!.validate()) return;
              if (documentPath == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please upload document"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

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
                latitude: "22.7196",
                longitude: "75.8577",
                totalComputers: totalComputerCtrl.text,
                openingTime: openingCtrl.text,
                closingTime: closingCtrl.text,
                gstNumber: gstCtrl.text,
                documentPath: documentPath!,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? "✅ Cyber Cafe registered successfully"
                      : "❌ Registration failed"),
                  backgroundColor:
                  success ? Colors.green : Colors.red,
                ),
              );
            },
            child: provider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Register Cafe"),
          ),
        );
      },
    );
  }
}
