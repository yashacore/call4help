import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/data/models/pending_list_booking.dart';
import 'package:first_flutter/providers/booking_status_provider.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/booking_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderSlotsDashboard extends StatefulWidget {
  const ProviderSlotsDashboard({super.key});

  @override
  State<ProviderSlotsDashboard> createState() =>
      _ProviderSlotsDashboardState();
}

class _ProviderSlotsDashboardState extends State<ProviderSlotsDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    Future.microtask(() {
      context.read<ProviderSlotsStatusProvider>().fetchByStatus('pending');
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          context
              .read<ProviderSlotsStatusProvider>()
              .fetchByStatus('pending');
        } else {
          context
              .read<ProviderSlotsStatusProvider>()
              .fetchAllBookings();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: ColorConstant.appColor,
        foregroundColor: Colors.white,
        title: const Text("Slot Bookings"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "All Bookings"),
          ],
        ),
      ),
      body: Consumer<ProviderSlotsStatusProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.bookings.isEmpty) {
            return const Center(child: Text("No bookings found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.bookings.length,
            itemBuilder: (context, index) {
              final booking = provider.bookings[index];
              return _bookingCard(booking);
            },
          );
        },
      ),
    );
  }

  Widget _bookingCard(PendingSlotBooking booking) {
    final slot = booking.slot;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailsScreen(booking: booking),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// SLOT TIME
            Text(
              "${slot.startTime} - ${slot.endTime}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            /// SEATS
            Text(
              "Seats: ${slot.availableSeats}/${slot.totalSeats}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 10),

            /// PRICE + STATUS TAG
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "₹${booking.totalAmount}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                /// ✅ ONLY STATUS CHIP (NO ACTIONS)
                _statusChip(booking.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final Color color = switch (status) {
      'completed' => Colors.green,
      'accepted' => Colors.blue,
      'rejected' => Colors.red,
      'pending' => Colors.orange,
      _ => Colors.grey,
    };

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withOpacity(0.12),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
