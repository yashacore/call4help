import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/provider_bank_model.dart';
import 'package:first_flutter/providers/vendor_bank_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderBankScreen extends StatefulWidget {
  const ProviderBankScreen({super.key});

  @override
  State<ProviderBankScreen> createState() => _ProviderBankScreenState();
}

class _ProviderBankScreenState extends State<ProviderBankScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _accCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: const Text("Bank Details"),
      ),

      body: Consumer<VendorBankProvider>(
        builder: (context, provider, _) {
          final double topOffset =
              MediaQuery.of(context).padding.top + kToolbarHeight;

          return Stack(
            children: [
              /// 🔷 Header Gradient
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ColorConstant.appColor,
                      ColorConstant.appColor.withValues(alpha:0.9),
                    ],
                  ),
                ),
              ),

              /// 📄 Form Card
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  topOffset-20 ,
                  16,
                  100,
                ),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Add Bank Account",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Your payout will be sent to this account",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),

                          _field(
                            label: "Account Holder Name",
                            controller: _nameCtrl,
                            icon: Icons.person,
                          ),
                          _field(
                            label: "Account Number",
                            controller: _accCtrl,
                            keyboard: TextInputType.number,
                            icon: Icons.credit_card,
                          ),
                          _field(
                            label: "IFSC Code",
                            controller: _ifscCtrl,
                            icon: Icons.account_balance,
                          ),
                          _field(
                            label: "Bank Name",
                            controller: _bankCtrl,
                            icon: Icons.apartment,
                          ),

                          if (provider.error != null) ...[
                            const SizedBox(height: 12),
                            _statusMessage(
                              provider.error!,
                              Colors.red,
                              Icons.error_outline,
                            ),
                          ],

                          if (provider.isSuccess) ...[
                            const SizedBox(height: 12),
                            _statusMessage(
                              "Bank details saved successfully",
                              Colors.green,
                              Icons.check_circle_outline,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// 🚀 Bottom Button
              Positioned(
                left: 16,
                right: 16,
                bottom: 20,
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstant.appColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    onPressed: provider.isLoading
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        provider.addBankDetails(
                          ProviderBankModel(
                            accountHolderName:
                            _nameCtrl.text.trim(),
                            accountNumber:
                            _accCtrl.text.trim(),
                            ifsc: _ifscCtrl.text.trim(),
                            bankName:
                            _bankCtrl.text.trim(),
                          ),
                        );
                      }
                    },
                    child: provider.isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      "Save Bank Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 🔹 Input Field
  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: const Color(0xffF9FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// 🔔 Status Message
  Widget _statusMessage(
      String text,
      Color color,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
