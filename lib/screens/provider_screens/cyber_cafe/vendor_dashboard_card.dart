import 'package:first_flutter/providers/dashboard_summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardSummaryProvider()..fetchDashboardSummary(),
      child: Consumer<DashboardSummaryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final data = provider.summary!;

          return GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.4, // 👈 SMALL HEIGHT
            children: [
              _miniStatCard(
                title: "Total Bookings",
                value: data.totalBookings,
                icon: Icons.list_alt,
                bgColor: const Color(0xFFE8F1FD),
                iconColor: const Color(0xFF1E88E5),
              ),
              _miniStatCard(
                title: "Today Bookings",
                value: data.todayBookings,
                icon: Icons.today,
                bgColor: const Color(0xFFE6F7F1),
                iconColor: const Color(0xFF009688),
              ),
              _miniStatCard(
                title: "Pending Bookings",
                value: data.pending,
                icon: Icons.hourglass_top,
                bgColor: const Color(0xFFFFF4E5),
                iconColor: const Color(0xFFFF9800),
              ),
              _miniStatCard(
                title: "Completed Bookings",
                value: data.completed,
                icon: Icons.check_circle,
                bgColor: const Color(0xFFE9F7EF),
                iconColor: const Color(0xFF4CAF50),
              ),
              _miniStatCard(
                title: "Cancelled Bookings",
                value: data.cancelled,
                icon: Icons.cancel,
                bgColor: const Color(0xFFFFEBEE),
                iconColor: const Color(0xFFD32F2F),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _miniStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // ICON
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha:0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),

          const SizedBox(width: 8),

          // TEXT (CONSTRAINED)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
