import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/vendor_notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VendorNotificationScreen extends StatefulWidget {
  const VendorNotificationScreen({super.key});

  @override
  State<VendorNotificationScreen> createState() =>
      _VendorNotificationScreenState();
}

class _VendorNotificationScreenState extends State<VendorNotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorNotificationProvider>().fetchVendorNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldGray,
      appBar: AppBar(
        backgroundColor: ColorConstant.appColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Vendor Notifications'),
      ),
      body: Consumer<VendorNotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.notifications.isEmpty) {
            return const Center(child: Text('No notifications found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = provider.notifications[index];

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: item.isRead ? Colors.white : Colors.blue.withAlpha(08),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(05), blurRadius: 6),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      item.type == 'order_accepted'
                          ? Icons.check_circle
                          : item.type == 'order_rejected'
                          ? Icons.cancel
                          : Icons.notifications,
                      color: item.type == 'order_accepted'
                          ? Colors.green
                          : item.type == 'order_rejected'
                          ? Colors.red
                          : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.message,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.createdAt.toLocal().toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
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
}
