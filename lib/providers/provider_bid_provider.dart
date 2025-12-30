import 'dart:async';
import 'dart:convert';
import 'package:first_flutter/data/models/ProviderBidModel.dart';
import 'package:first_flutter/nats_service/nats_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderBidProvider extends ChangeNotifier {
  final NatsService _natsService = NatsService();

  String? _currentTopic;
  StreamSubscription<bool>? _connectionSubscription;

  final List<ProviderBidModel> _bids = [];
  bool _isLoading = false;
  bool _isConnected = false;
  String? _error;
  int? _providerId;

  List<ProviderBidModel> get bids => _bids;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String? get error => _error;
  int? get providerId => _providerId;

  ProviderBidProvider() {
    debugPrint('🧩 ProviderBidProvider initialized');

    _connectionSubscription =
        _natsService.connectionStream.listen((connected) {
          debugPrint('🌐 NATS connection state changed → $connected');

          _isConnected = connected;

          if (connected) {
            _error = null;
            debugPrint('✅ NATS connected');

            if (_currentTopic != null) {
              debugPrint(
                '🔁 Reconnected → subscription active for $_currentTopic',
              );
            }
          } else {
            _error = 'Connection lost. Reconnecting...';
            debugPrint('❌ NATS disconnected');
          }

          notifyListeners();
        });

    _isConnected = _natsService.isConnected;
    debugPrint('📡 Initial NATS connection: $_isConnected');
  }

  /// Remove bid from list (called when timer expires)
  void removeBid(String bidId) {
    debugPrint('🗑️ removeBid called → bidId: $bidId');

    final bidIndex = _bids.indexWhere((bid) => bid.id == bidId);
    if (bidIndex != -1) {
      final bid = _bids[bidIndex];
      _bids.removeAt(bidIndex);
      notifyListeners();

      debugPrint(
        '🗑️ Bid removed: ${bid.title} (ID: $bidId) – timer expired',
      );
    } else {
      debugPrint('⚠️ removeBid: bid not found');
    }
  }

  /// Initialize subscription to provider-specific topic
  Future<void> initialize() async {
    debugPrint('🚀 initialize() called');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔐 Fetching provider_id from SharedPreferences');

      final prefs = await SharedPreferences.getInstance();
      _providerId = prefs.getInt('provider_id');

      debugPrint('👤 providerId: $_providerId');

      if (_providerId == null) {
        _error = 'Provider ID not found. Please login again.';
        _isLoading = false;
        notifyListeners();

        debugPrint('❌ Provider ID missing');
        return;
      }

      if (!_natsService.isConnected) {
        debugPrint('⏳ Waiting for NATS connection...');

        int attempts = 0;
        while (!_natsService.isConnected && attempts < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          attempts++;
          debugPrint('⏳ NATS connect attempt: $attempts');
        }

        if (!_natsService.isConnected) {
          _error = 'Failed to connect to NATS server';
          _isLoading = false;
          notifyListeners();

          debugPrint('❌ NATS connection failed');
          return;
        }
      }

      _isConnected = true;
      debugPrint('✅ NATS is connected');

      if (_currentTopic != null) {
        debugPrint('🔕 Unsubscribing from old topic: $_currentTopic');
        _natsService.unsubscribe(_currentTopic!);
      }

      _currentTopic = 'services.provider.$_providerId';
      debugPrint('📡 Subscribing to topic: $_currentTopic');

      _natsService.subscribe(
        _currentTopic!,
        _handleBidNotification,
      );

      debugPrint('🎧 Listening for service requests...');
      _error = null;

      _isLoading = false;
      notifyListeners();

      debugPrint('✅ initialize() completed');
    } catch (e) {
      _error = 'Initialization error: $e';
      _isLoading = false;
      _isConnected = false;
      notifyListeners();

      debugPrint('❌ Initialization exception: $e');
    }
  }

  /// Handle incoming bid notifications
  void _handleBidNotification(String message) {
    debugPrint('📩 Incoming NATS message');
    debugPrint('📄 Raw payload: $message');

    try {
      final data = jsonDecode(message);
      final bid = ProviderBidModel.fromJson(data);

      debugPrint('📦 Parsed bid → ID: ${bid.id}');
      debugPrint('📌 Status: ${bid.status}');

      if (bid.status == 'open') {
        final existingIndex = _bids.indexWhere((b) => b.id == bid.id);

        if (existingIndex != -1) {
          _bids[existingIndex] =
              bid.copyWith(receivedAt: DateTime.now());

          debugPrint('🔄 Updated existing bid: ${bid.title}');
        } else {
          final newBid =
          bid.copyWith(receivedAt: DateTime.now());

          _bids.insert(0, newBid);

          debugPrint('🆕 New bid added: ${bid.title}');
          debugPrint('⏱️ Timer started at ${newBid.receivedAt}');
        }

        debugPrint('💰 Budget: ${bid.formattedBudget}');
        debugPrint('📍 Location: ${bid.location}');
        debugPrint(
          '🗓️ Schedule: ${bid.scheduleDate} ${bid.scheduleTime}',
        );

        notifyListeners();
      } else {
        debugPrint(
          '⏭️ Ignored bid (status: ${bid.status})',
        );
      }
    } catch (e) {
      debugPrint('❌ Error handling notification: $e');
      debugPrint('📄 Failed message: $message');

      _error = 'Error processing notification: $e';
      notifyListeners();
    }
  }

  /// Manually add a bid (testing)
  void addBid(ProviderBidModel bid) {
    debugPrint('➕ addBid called → ${bid.id}');

    final index = _bids.indexWhere((b) => b.id == bid.id);

    if (index != -1) {
      _bids[index] =
          bid.copyWith(receivedAt: DateTime.now());

      debugPrint('🔄 Updated manual bid');
    } else {
      _bids.insert(0, bid.copyWith(receivedAt: DateTime.now()));

      debugPrint('🆕 Manually added new bid');
    }

    notifyListeners();
  }

  /// Clear all bids
  void clearBids() {
    debugPrint('🧹 Clearing all bids (${_bids.length})');
    _bids.clear();
    notifyListeners();
  }

  /// Retry connection and subscription
  Future<void> retry() async {
    debugPrint('🔁 Retry requested');

    if (!_natsService.isConnected) {
      debugPrint('🔌 Attempting NATS reconnect');
      await _natsService.reconnect();
      await Future.delayed(const Duration(seconds: 1));
    }

    await initialize();
  }

  /// Get bid by ID
  ProviderBidModel? getBidById(String id) {
    debugPrint('🔍 getBidById called → $id');

    try {
      return _bids.firstWhere((bid) => bid.id == id);
    } catch (_) {
      debugPrint('⚠️ Bid not found');
      return null;
    }
  }

  /// Refresh UI
  Future<void> refresh() async {
    debugPrint('🔄 refresh() called');
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('🧨 Disposing ProviderBidProvider');

    _connectionSubscription?.cancel();

    if (_currentTopic != null) {
      debugPrint('🔕 Unsubscribing from $_currentTopic');
      _natsService.unsubscribe(_currentTopic!);
    }

    super.dispose();
  }
}
