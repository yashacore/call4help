import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/register_cafe_provider.dart';
import 'package:first_flutter/widgets/button_large.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditCafeScreen extends StatefulWidget {
  final dynamic cafe; // your Cafe model / response object

  const EditCafeScreen({super.key, required this.cafe});

  @override
  State<EditCafeScreen> createState() => _EditCafeScreenState();
}

class _EditCafeScreenState extends State<EditCafeScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController shopNameCtrl;
  late TextEditingController ownerNameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController cityCtrl;
  late TextEditingController stateCtrl;
  late TextEditingController pincodeCtrl;
  late TextEditingController address1Ctrl;
  late TextEditingController address2Ctrl;
  late TextEditingController totalComputerCtrl;
  late TextEditingController openingCtrl;
  late TextEditingController closingCtrl;
  late TextEditingController gstCtrl;

  List<File> shopImages = [];
  List<File> documents = [];

  @override
  void initState() {
    super.initState();

    /// ✅ PREFILL CONTROLLERS
    shopNameCtrl = TextEditingController(text: widget.cafe.shopName);
    ownerNameCtrl = TextEditingController(text: widget.cafe.ownerName);
    phoneCtrl = TextEditingController(text: widget.cafe.phone);
    emailCtrl = TextEditingController(text: widget.cafe.email);
    cityCtrl = TextEditingController(text: widget.cafe.city);
    stateCtrl = TextEditingController(text: widget.cafe.state);
    pincodeCtrl = TextEditingController(text: widget.cafe.pincode);
    address1Ctrl = TextEditingController(text: widget.cafe.addressLine1);
    address2Ctrl = TextEditingController(text: widget.cafe.addressLine2);
    totalComputerCtrl =
        TextEditingController(text: widget.cafe.totalComputers.toString());
    openingCtrl =
        TextEditingController(text: widget.cafe.openingTime.substring(0, 5));
    closingCtrl =
        TextEditingController(text: widget.cafe.closingTime.substring(0, 5));
    gstCtrl = TextEditingController(text: widget.cafe.gstNumber);
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      ctrl.text =
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _pickFiles(bool isImage) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: isImage ? FileType.image : FileType.custom,
      allowedExtensions: isImage ? null : ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        final files = result.paths.map((e) => File(e!)).toList();
        if (isImage) {
          shopImages = files;
        } else {
          documents = files;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Cafe"),
        backgroundColor: ColorConstant.appColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: ColorConstant.scaffoldGray,
      body: Consumer<RegisterCafeProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _card([
                        _input("Shop Name", shopNameCtrl),
                        _input("Owner Name", ownerNameCtrl),
                        _input("Phone", phoneCtrl,
                            keyboard: TextInputType.phone),
                        _input("Email", emailCtrl,
                            keyboard: TextInputType.emailAddress),
                        _input("City", cityCtrl),
                        _input("State", stateCtrl),
                        _input("Pincode", pincodeCtrl,
                            keyboard: TextInputType.number),
                        _input("Address Line 1", address1Ctrl),
                        _input("Address Line 2", address2Ctrl),
                        _input("Total Computers", totalComputerCtrl,
                            keyboard: TextInputType.number),
                        _timeField("Opening Time", openingCtrl),
                        _timeField("Closing Time", closingCtrl),
                        _input("GST Number", gstCtrl),
                      ]),
                      const SizedBox(height: 16),
                      _filePicker("Upload Shop Images", true),
                      const SizedBox(height: 12),
                      _filePicker("Upload Documents", false),
                      const SizedBox(height: 24),
                      ButtonLarge(
                        onTap: provider.isLoading
                            ? null
                            : () async {
                          if (!_formKey.currentState!.validate()) return;

                          final ok =
                          await provider.updateCafe(
                            cafeId: widget.cafe.id,
                            shopName: shopNameCtrl.text.trim(),
                            ownerName: ownerNameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            city: cityCtrl.text.trim(),
                            state: stateCtrl.text.trim(),
                            pincode: pincodeCtrl.text.trim(),
                            addressLine1: address1Ctrl.text.trim(),
                            addressLine2: address2Ctrl.text.trim(),
                            latitude: widget.cafe.latitude,
                            longitude: widget.cafe.longitude,
                            totalComputers:
                            int.parse(totalComputerCtrl.text),
                            openingTime: openingCtrl.text,
                            closingTime: closingCtrl.text,
                            gstNumber: gstCtrl.text.trim(),
                            shopImages:
                            shopImages.isEmpty ? null : shopImages,
                            documents:
                            documents.isEmpty ? null : documents,
                          );

                          if (ok && context.mounted) {
                            Navigator.pop(context, true);
                          }
                        },
                        label: "Update Cafe",

                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _input(String label, TextEditingController ctrl,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        validator: (v) =>
        v == null || v.isEmpty ? "$label required" : null,
        decoration: InputDecoration(
          labelText: label,
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

  Widget _timeField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        readOnly: true,
        onTap: () => _pickTime(ctrl),
        validator: (v) =>
        v == null || v.isEmpty ? "$label required" : null,
        decoration: InputDecoration(
          labelText: label,
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

  Widget _filePicker(String label, bool isImage) {
    return InkWell(
      onTap: () => _pickFiles(isImage),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ColorConstant.appColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.upload_file),
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}
