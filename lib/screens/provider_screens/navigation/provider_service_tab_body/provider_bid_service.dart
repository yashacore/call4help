import 'package:first_flutter/providers/ProviderBidProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/provider_service_list_card.dart';
import '../../provider_service_details_screen.dart';

class ProviderBidService extends StatefulWidget {
  const ProviderBidService({super.key});

  @override
  State<ProviderBidService> createState() => _ProviderBidServiceState();
}

class _ProviderBidServiceState extends State<ProviderBidService> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProviderBidProvider>();
      if (!provider.isConnected || provider.providerId == null) {
        provider.initialize();
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not scheduled';
    return DateFormat('MMM dd, yyyy').format(date);
  }


  String _getDisplayDate(dynamic bid) {
    if (bid.scheduleDate != null) {
      return _formatDate(bid.scheduleDate);
    } else if (bid.startDate != null) {
      return _formatDate(bid.startDate);
    } else {
      return _formatDate(bid.createdAt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProviderBidProvider>(
        builder: (context, bidProvider, child) {
          if (bidProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Setting up service listener...'),
                ],
              ),
            );
          }
          if (bidProvider.error != null && !bidProvider.isConnected) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      bidProvider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => bidProvider.retry(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Connection'),
                  ),
                ],
              ),
            );
          }
          if (bidProvider.bids.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No service requests yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You will see new requests here automatically',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  if (bidProvider.isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Listening for requests...',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await bidProvider.refresh();
            },
            child: ListView.builder(
              itemCount: bidProvider.bids.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final bid = bidProvider.bids[index];
                return ProviderServiceListCard(
                  key: ValueKey(bid.id),
                  category: bid.category,
                  subCategory: bid.service,
                  date: _getDisplayDate(bid),
                  dp: "https://picsum.photos/200/200?random=${bid.id}",
                  price: bid.budget.toStringAsFixed(2),
                  duration: bid.durationDisplay,
                  priceBy: bid.tenure == 'one_time' ? 'One Time' : bid.tenure,
                  providerCount: null,
                  status: bid.status,
                  createdAt: bid.receivedAt,
                  timerDurationMinutes: 1,
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProviderServiceDetailsScreen(serviceId: bid.id),
                      ),
                    ).then((_) {
                      final provider = context.read<ProviderBidProvider>();
                      if (!provider.isConnected ||
                          provider.providerId == null) {
                        provider.initialize();
                      }
                    });
                  },
                  onTimerComplete: () {
                    debugPrint(
                      '⏱️ Timer expired for bid: ${bid.id} - ${bid.title}',
                    );
                    bidProvider.removeBid(bid.id);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
