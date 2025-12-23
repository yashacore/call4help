import 'package:first_flutter/providers/user_notification_provider.dart';
import 'package:first_flutter/screens/user_screens/cyber_cafe/booking_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserNotificationsScreen extends StatefulWidget {
  const UserNotificationsScreen({super.key});

  @override
  State<UserNotificationsScreen> createState() =>
      _UserNotificationsScreenState();
}

class _UserNotificationsScreenState extends State<UserNotificationsScreen> {
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NotificationProviderUser>().fetchNotifications();
    });
  }

  IconData _iconByType(String type) {
    switch (type) {
      case 'order_accepted':
        return Icons.check_circle;
      case 'order_rejected':
        return Icons.cancel;
      case 'slot_booked':
        return Icons.event_seat;
      default:
        return Icons.notifications;
    }
  }

  Color _colorByType(String type) {
    switch (type) {
      case 'order_accepted':
        return Colors.green;
      case 'order_rejected':
        return Colors.red;
      case 'slot_booked':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProviderUser>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIds.isNotEmpty
              ? 'Selected (${_selectedIds.length})'
              : 'Notifications',
        ),
        centerTitle: true,
        actions: [
          if (_selectedIds.isNotEmpty)
            IconButton(
              tooltip: 'Mark selected as read',
              icon: const Icon(Icons.done_all),
              onPressed: () async {
                await context
                    .read<NotificationProviderUser>()
                    .markSelectedAsRead(_selectedIds.toList());

                setState(() => _selectedIds.clear());
              },
            ),
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.mark_email_read_outlined),
            onPressed: () async {
              await context
                  .read<NotificationProviderUser>()
                  .markAllAsRead();
              setState(() => _selectedIds.clear());
            },
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.notifications.length,
            itemBuilder: (_, i) {
              final n = provider.notifications[i];
              final isSelected = _selectedIds.contains(n.id);

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  if (n.orderId.isNotEmpty) {
                    if (!n.isRead) {
                      context
                          .read<NotificationProviderUser>()
                          .markAsRead(n.id);
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookingDetailScreen(orderId: n.orderId),
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withOpacity(.12)
                        : n.isRead
                        ? Colors.white
                        : Colors.blue.withOpacity(.05),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.06),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                        _colorByType(n.type).withOpacity(.15),
                        child: Icon(
                          _iconByType(n.type),
                          color: _colorByType(n.type),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n.message,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      /// ✅ ALWAYS VISIBLE CHECKBOX
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedIds.add(n.id);
                            } else {
                              _selectedIds.remove(n.id);
                            }
                          });
                        },
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
