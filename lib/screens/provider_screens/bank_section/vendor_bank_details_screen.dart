import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/vendor_bank_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderBankDetailsScreen extends StatefulWidget {
  const ProviderBankDetailsScreen({super.key});

  @override
  State<ProviderBankDetailsScreen> createState() =>
      _ProviderBankDetailsScreenState();
}

class _ProviderBankDetailsScreenState
    extends State<ProviderBankDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorBankProvider>().fetchBankDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        backgroundColor: ColorConstant.appColor,
        foregroundColor: Colors.white,
        title: const Text("Bank Account"),
        centerTitle: true,
      ),
      body: Consumer<VendorBankProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final data = provider.bankDetails;
          if (data == null) {
            return const Center(child: Text("No bank details found"));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// 🔷 Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorConstant.appColor,
                        ColorConstant.appColor.withOpacity(0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance,
                          color: Colors.white, size: 34),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.bankName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _statusChip(data.isVerified),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// 📄 Details Card
                _infoTile("Account Holder", data.accountHolderName),
                _infoTile(
                  "Account Number",
                  "•••• ${data.accountNumber.substring(data.accountNumber.length - 4)}",
                ),
                _infoTile("IFSC Code", data.ifsc),
                _infoTile(
                  "Added On",
                  data.createdAt.toLocal().toString().split('.').first,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(bool verified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: verified
            ? Colors.green.withOpacity(0.15)
            : Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        verified ? "Verified" : "Pending Verification",
        style: TextStyle(
          color: verified ? Colors.green : Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
