import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/data/models/pending_list_booking.dart';
import 'package:first_flutter/providers/booking_status_provider.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/booking_list.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/cyber_landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingDetailsScreen extends StatelessWidget {
  final PendingSlotBooking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final slot = booking.slot;

    return Consumer<ProviderSlotsStatusProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          appBar: AppBar(
            backgroundColor: ColorConstant.appColor,
            foregroundColor: Colors.white,
            title: const Text("Booking Details"),
            centerTitle: true,
          ),

          /// 🔥 DYNAMIC ACTION BAR
          bottomNavigationBar: _buildBottomBar(context, provider),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoCard(
                  title: "Slot Timing",
                  value: "${slot.startTime} - ${slot.endTime}",
                  icon: Icons.access_time,
                ),
                _infoCard(
                  title: "Seats",
                  value:
                      "${slot.availableSeats}/${slot.totalSeats} seats available",
                  icon: Icons.event_seat,
                ),
                _infoCard(
                  title: "Total Amount",
                  value: "₹${booking.totalAmount}",
                  icon: Icons.currency_rupee,
                  highlight: true,
                ),
                _infoCard(
                  title: "Order ID",
                  value: booking.orderId,
                  icon: Icons.receipt_long,
                ),
                _infoCard(
                  title: "Status",
                  value: provider.currentStatus.toUpperCase(),
                  icon: Icons.info_outline,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ================= BOTTOM BAR =================
  Widget? _buildBottomBar(
    BuildContext context,
    ProviderSlotsStatusProvider provider,
  ) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    /// 🟡 PENDING
    if (provider.currentStatus == 'pending') {
      return _actionBar([
        _actionButton(
          "Reject",
          Colors.red,
          () => provider.rejectBooking(booking.orderId),
        ),
        _actionButton(
          "Approve",
          Colors.green,
          () => provider.approveBooking(
            orderId: booking.orderId,
            notes: "Booking approved by provider",
          ),


        ),
      ]);
    }

    /// 🟢 APPROVED
    if (provider.currentStatus == 'accepted') {
      return _actionBar([
        _actionButton(
          "Complete Booking",
          Colors.blue,
              () async {
            await provider.completeBooking(
              orderId: booking.orderId,
              notes: "Service completed successfully",
            );

            if (!context.mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CyberLandingScreen(),
              ),
            );
          },
        ),

      ]);
    }

    return null;
  }

  Widget _actionBar(List<Widget> buttons) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: buttons
              .map(
                (e) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: e,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    bool highlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: highlight
                ? Colors.green.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
            child: Icon(icon, color: highlight ? Colors.green : Colors.blue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
