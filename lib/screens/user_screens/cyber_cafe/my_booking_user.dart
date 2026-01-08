import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/my_bookings_user_provider.dart';
import 'package:first_flutter/screens/user_screens/user_custom_bottom_nav.dart';
import 'package:first_flutter/widgets/button_large.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyBookingUser extends StatelessWidget {
  const MyBookingUser({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyBookingsUserProvider()..fetchMyBookings(),
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ButtonLarge(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => (
                      UserCustomBottomNav()
                  ),
                ),
              );
            },
            label: "Back to home",
          ),
        ),
        appBar: AppBar(
          backgroundColor: ColorConstant.appColor,
          foregroundColor: Colors.white,
          title: const Text("My Bookings"),
          centerTitle: true,
        ),
        body: Consumer<MyBookingsUserProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }

            if (provider.bookings.isEmpty) {
              return const Center(child: Text("No bookings found"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.bookings.length,
              itemBuilder: (context, index) {
                final booking = provider.bookings[index];
                final details = provider.orderDetailsMap[booking.id];
                final isLoading =
                provider.loadingOrders.contains(booking.id);

                return InkWell(
                  onTap: () {
                    provider.fetchOrderDetails(booking.id);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.06),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 📌 BASIC INFO
                        Text(
                          "Order ID: ${booking.id}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text("Amount: ₹${booking.totalAmount}"),
                        const SizedBox(height: 10),

                        /// STATUS + CANCEL
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(booking.status.toUpperCase()),
                              backgroundColor:
                              _statusColor(booking.status).withValues(alpha:0.15),
                              labelStyle: TextStyle(
                                color: _statusColor(booking.status),
                              ),
                            ),

                            if (booking.status == 'created' ||
                                booking.status == 'accepted')
                              TextButton.icon(
                                icon: const Icon(Icons.cancel,
                                    color: Colors.red),
                                label: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title:
                                      const Text("Cancel Booking"),
                                      content: const Text(
                                          "Are you sure you want to cancel this booking?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("No"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text(
                                            "Yes, Cancel",
                                            style:
                                            TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm != true) return;

                                  final success =
                                  await provider.cancelBooking(
                                    orderId: booking.id,
                                  );

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? "Booking cancelled successfully"
                                            : provider.error ??
                                            "Cancel failed",
                                      ),
                                      backgroundColor: success
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),

                        /// 🔽 LOADING DETAILS
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child:
                            Center(child: CircularProgressIndicator()),
                          ),

                        /// 📄 DETAILS
                        if (details != null) ...[
                          const Divider(height: 24),

                          Text(
                            details.cafe?.shopName ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(details.cafe?.address ?? ''),
                          Text("📞 ${details.cafe?.phone ?? ''}"),
                          const SizedBox(height: 10),

                          Text(
                            "Time: ${details.slot?.startTime} - ${details.slot?.endTime}",
                          ),
                          const SizedBox(height: 6),

                          Text("Payment: ${details.paymentStatus}"),
                          Text(
                            "Booked on: ${details.createdAt.substring(0, 10)}",
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}
