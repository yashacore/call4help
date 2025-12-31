import 'package:first_flutter/data/models/pending_list_booking.dart';
import 'package:first_flutter/providers/booking_status_provider.dart';
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

  final tabs = ['pending', 'approve', 'rejected', 'completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);

    Future.microtask(() {
      context.read<ProviderSlotsStatusProvider>().fetchByStatus('pending');
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        context
            .read<ProviderSlotsStatusProvider>()
            .fetchByStatus(tabs[_tabController.index]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Slot Bookings"),
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "approve"),
            Tab(text: "Rejected"),
            Tab(text: "Completed"),
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
              final slot = booking.slot;

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
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Time
                    Text(
                      "${slot.startTime} - ${slot.endTime}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// Seats
                    Text(
                      "Seats: ${slot.availableSeats}/${slot.totalSeats}",
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "₹${booking.totalAmount}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        _actionButtons(provider, booking),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _actionButtons(
      ProviderSlotsStatusProvider provider,
      PendingSlotBooking booking,
      ) {
    if (provider.currentStatus == 'pending') {
      return Row(
        children: [
          _actionBtn(
            "Reject",
            Colors.red,
                () => provider.rejectBooking(booking.orderId),
          ),
          const SizedBox(width: 8),
          _actionBtn(
            "approve",
            Colors.green,
                () => provider.approveBooking(orderId: booking.orderId, notes: "Booking approved for customer"),
          ),
        ],
      );
    }

    if (provider.currentStatus == 'approve') {
      return _actionBtn(
        "Complete",
        Colors.blue,
            () => provider.completeBooking(booking.orderId),
      );
    }

    return Chip(
      label: Text(
        provider.currentStatus.toUpperCase(),
      ),
    );
  }

  Widget _actionBtn(String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onTap,
      child: Text(text),
    );
  }
}
