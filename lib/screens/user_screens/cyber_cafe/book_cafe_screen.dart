import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/provider_slots_booking_provider.dart';
import 'package:first_flutter/screens/user_screens/cyber_cafe/my_booking_user.dart';
import 'package:first_flutter/widgets/button_large.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookSlotScreen extends StatefulWidget {
  final String slotId;

  const BookSlotScreen({super.key, required this.slotId});

  @override
  State<BookSlotScreen> createState() => _BookSlotScreenState();
}

class _BookSlotScreenState extends State<BookSlotScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController durationCtrl =
  TextEditingController(text: "1 hour");
  final TextEditingController pcTypeCtrl =
  TextEditingController(text: "gaming");

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderSlotBookingProvider>();

    return Scaffold(
      bottomNavigationBar:
      provider.isLoading
          ? Center(child: const CircularProgressIndicator())
          : SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ButtonLarge(
              onTap: () async {
                if (!_formKey.currentState!.validate()) return;

                final success =
                await provider.bookSlot(
                  slotId:widget.slotId,
                  subcategoryId: "57",
                  totalAmount: 500,
                  baseAmount: 400,
                  extraCharges: 5,
                  discountAmount: -5,
                  inputFields: {
                    "duration": durationCtrl.text,
                    "pc_type": pcTypeCtrl.text,
                  },
                  uploadedFiles: [
                    {
                      "file_name": "aadhar.pdf",
                      "file_url":
                      "https://example.com/aadhar.pdf",
                    }
                  ],
                );

                if (!context.mounted) return;

                if (success) {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyBookingUser(

                      ),
                    ),
                  );


                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                      Text("Slot booked successfully"),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                      Text(provider.error ?? "Error"),
                    ),
                  );
                }
              },
              label: "Confirm Booking",
            ),
          ),),
      appBar: AppBar(
        backgroundColor: ColorConstant.appColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text("Book Slot")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _inputField("Duration", durationCtrl),
              _inputField("PC Type", pcTypeCtrl),

              const SizedBox(height: 20),

              _priceTile("Base Amount", "₹400"),
              _priceTile("Extra Charges", "₹5"),
              _priceTile("Discount", "-₹5"),
              _priceTile("Total Amount", "₹500", highlight: true),

              const SizedBox(height: 30),




            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _priceTile(String label, String value,
      {bool highlight = false}) {
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
