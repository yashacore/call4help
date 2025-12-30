import 'package:first_flutter/data/api_services/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationTestScreen extends StatelessWidget {
  const NotificationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification Test")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            ElevatedButton(
              onPressed: () async {
                await NotificationService.showTestNotification();
              },
              child: const Text("🔔 Test Local Notification"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () async {
                await NotificationService.showForegroundNotification(
                  "Foreground Test",
                  "Testing notification while app is open",
                );
              },
              child: const Text("📲 Test Foreground Notification"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () async {
                final token = await NotificationService.getDeviceToken();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("FCM Token:\n$token")),
                );
              },
              child: const Text("🔑 Show FCM Token"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () async {
                await NotificationService.requestNotificationPermission(
                  context,
                );
              },
              child: const Text("📢 Request Permission"),
            ),
          ],
        ),
      ),
    );
  }
}
