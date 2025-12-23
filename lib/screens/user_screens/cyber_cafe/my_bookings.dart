import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/booking_cyber_user_provider.dart';
import 'package:first_flutter/providers/booking_details_provider.dart';
import 'package:first_flutter/screens/user_screens/cyber_cafe/booking_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCyberBookings extends StatefulWidget {
  const MyCyberBookings({super.key});

  @override
  State<MyCyberBookings> createState() => _UserBookingsScreenState();
}

class _UserBookingsScreenState extends State<MyCyberBookings> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => context.read<BookingCyberServiceProvider>().fetchBookings(),
    );
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

          title: const Text('My Bookings')),
      body: Consumer<BookingCyberServiceProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.bookings.isEmpty) {
            return const Center(child: Text('No bookings found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.bookings.length,
            itemBuilder: (_, i) {
              final b = provider.bookings[i];

              return InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => BookingDetailProvider(),
                        child: BookingDetailScreen(orderId: b.id),
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.06),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              b.shopName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(b.status).withOpacity(.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              b.status.toUpperCase(),
                              style: TextStyle(
                                color: _statusColor(b.status),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${b.city} • ${b.startTime} - ${b.endTime}'),
                      const SizedBox(height: 6),
                      Text(
                        '₹${b.totalAmount}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Payment: ${b.paymentStatus}',
                        style: TextStyle(
                          color: b.paymentStatus == 'pending'
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
