import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/booking_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingDetailScreen extends StatefulWidget {
  final String orderId;

  const BookingDetailScreen({super.key, required this.orderId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BookingDetailProvider>().fetchBookingDetail(widget.orderId);
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'created':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ColorConstant.appColor,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text('Booking Details'),
      ),
      body: Consumer<BookingDetailProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final b = provider.booking!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _card(
                title: 'Cafe Details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.cafe.shopName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Owner: ${b.cafe.ownerName}'),
                    Text('Phone: ${b.cafe.phone}'),
                    Text('${b.cafe.address1}, ${b.cafe.address2}'),
                    Text(b.cafe.city),
                  ],
                ),
              ),

              _card(
                title: 'Slot Details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${b.slot.date.split("T").first}'),
                    Text('Time: ${b.slot.startTime} - ${b.slot.endTime}'),
                    Text(
                      'Seats: ${b.slot.availableSeats}/${b.slot.totalSeats}',
                    ),
                  ],
                ),
              ),

              _card(
                title: 'Payment',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount: ₹${b.totalAmount}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Payment Status: ${b.paymentStatus}',
                      style: TextStyle(
                        color: b.paymentStatus == 'pending'
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              _card(
                title: 'Booking Status',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(b.status).withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        b.status.toUpperCase(),
                        style: TextStyle(
                          color: _statusColor(b.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Divider(),
          child,
        ],
      ),
    );
  }
}
