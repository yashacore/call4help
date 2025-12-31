import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/landing_screen_provider.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/booking_list.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/create_time_slot.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/edit_cyber_cafe_screen.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/get_working_hour.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/register_cafe.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/set_working_hour.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/time_slot_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CyberLandingScreen extends StatefulWidget {
  const CyberLandingScreen({super.key});

  @override
  State<CyberLandingScreen> createState() => _CyberLandingScreenState();
}

class _CyberLandingScreenState extends State<CyberLandingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProviderCafeProvider>().fetchMyCafe();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),
      appBar: AppBar(
        backgroundColor: ColorConstant.appColor,
        foregroundColor: Colors.white,
        title: const Text("My Cyber Cafe"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<ProviderCafeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final cafe = provider.cafe;
          if (cafe == null) {
            return const Center(child: Text("No cafe registered yet"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🟢 HEADER CARD
                _headerCard(cafe),

                const SizedBox(height: 16),

                /// ⚡ ACTION CARDS
                Row(
                  children: [
                    _actionCard(
                      icon: Icons.edit,
                      title: "Register Cafe",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CyberCafeRegisterScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _actionCard(
                      icon: Icons.schedule,
                      title: "Time Slot",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SlotsList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8,),
                Row(
                  children: [
                    _actionCard(
                      icon: Icons.watch_later,
                      title: "Set Working Hour",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SetWorkingHoursScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _actionCard(
                      icon: Icons.schedule,
                      title: "Working Hour List",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkingHoursViewScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _actionCard(
                  fullWidth: true,
                  icon: Icons.book_online,
                  title: "View Bookings",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProviderSlotsDashboard(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                /// 📋 DETAILS SECTION
                _sectionTitle("Cafe Details"),
                _infoGrid(cafe),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===================== UI COMPONENTS =====================

  Widget _headerCard(cafe) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cafe.shopName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              OutlinedButton(
                onPressed: () async {
                  final provider = context.read<ProviderCafeProvider>();
                  final cafe = provider.cafe;

                  if (cafe == null) return;

                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCafeScreen(cafe: cafe),
                    ),
                  );

                  /// 🔄 REFRESH AFTER UPDATE
                  if (updated == true) {
                    provider.fetchMyCafe();
                  }
                },
                child: const Text("Edit Cafe"),
              ),

            ],
          ),
          const SizedBox(height: 6),
          Text("Owner: ${cafe.ownerName}"),
          const SizedBox(height: 12),
          Row(
            children: [
              _statusChip(
                cafe.verificationStatus == "approved"
                    ? Colors.green
                    : Colors.orange,
                cafe.verificationStatus.toUpperCase(),
              ),
              const SizedBox(width: 10),
              _statusChip(
                cafe.isActive ? Colors.green : Colors.red,
                cafe.isActive ? "ACTIVE" : "INACTIVE",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return Expanded(
      flex: fullWidth ? 0 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.shade50,
                child: Icon(icon, color: Colors.blue),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoGrid(cafe) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow(Icons.phone, "Phone", cafe.phone),
          _infoRow(Icons.email, "Email", cafe.email),
          _infoRow(Icons.receipt_long, "GST", cafe.gstNumber),
          _infoRow(Icons.location_on, "Address",
              "${cafe.addressLine1}, ${cafe.addressLine2}"),
          _infoRow(Icons.location_city, "City", cafe.city),
          _infoRow(Icons.map, "State", cafe.state),
          _infoRow(Icons.pin, "Pincode", cafe.pincode),
          _infoRow(Icons.computer, "Total Computers",
              cafe.totalComputers.toString()),
          _infoRow(Icons.devices, "Available Computers",
              cafe.availableComputers.toString()),
          _infoRow(Icons.access_time, "Opening Time", cafe.openingTime),
          _infoRow(Icons.access_time_filled, "Closing Time", cafe.closingTime),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}


