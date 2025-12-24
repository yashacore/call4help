import 'package:first_flutter/config/baseControllers/APis.dart';
import 'package:first_flutter/nats_service/NatsService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_nats/dart_nats.dart';


class ProviderChatProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _chatId;
  List<ChatMessage> _messages = [];
  Subscription? _chatSubscription;
  final NatsService _natsService = NatsService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get chatId => _chatId;
  List<ChatMessage> get messages => _messages;

  Future<bool> fetchChatHistory({required String chatId}) async {
    debugPrint("=== FETCHING CHAT HISTORY ===");
    debugPrint("Chat ID: $chatId");

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_natsService.isConnected) {
        debugPrint("NATS not connected, attempting to connect...");
        final connected = await _natsService.connect();
        if (!connected) {
          _error = 'Failed to connect to messaging service';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      final requestPayload = {'chat_id': int.parse(chatId)};
      debugPrint("📩 Sending NATS request: $requestPayload");

      final responseStr = await _natsService.request(
        'chat.history.request',
        json.encode(requestPayload),
        timeout: Duration(seconds: 5),
      );

      if (responseStr == null) {
        _error = 'No response from chat service';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final responseData = json.decode(responseStr);
      debugPrint("✅ Received NATS Response:");
      debugPrint(responseData);

      if (responseData['success'] == true && responseData['messages'] != null) {
        _messages.clear();

        List<dynamic> messagesData = responseData['messages'];
        for (var msgData in messagesData) {
          try {
            final chatMessage = ChatMessage.fromJson(msgData);
            _messages.add(chatMessage);
          } catch (e) {
            debugPrint("Error parsing message: $e");
          }
        }

        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        debugPrint("✅ Loaded ${_messages.length} messages from history");
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = responseData['message'] ?? 'Failed to fetch chat history';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("=== EXCEPTION in fetchChatHistory ===");
      debugPrint("Error: $e");
      debugPrint("Stack Trace: $stackTrace");
      _error = 'Failed to load chat history: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> subscribeToMessages({required String chatId}) async {
    try {
      debugPrint("=== Subscribing to chat messages ===");
      debugPrint("Chat ID: $chatId");

      if (!_natsService.isConnected) {
        debugPrint("NATS not connected, attempting to connect...");
        await _natsService.connect();
      }

      _chatSubscription = _natsService.subscribe('chat.message.$chatId', (message) {
        try {
          final msgData = json.decode(message);
          debugPrint("📨 New message received: $msgData");

          final chatMessage = ChatMessage.fromJson(msgData);

          bool exists = _messages.any((m) => m.id == chatMessage.id);
          if (!exists) {
            _messages.add(chatMessage);
            _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            notifyListeners();
            debugPrint("✅ New message added to list: ${chatMessage.id}");
          } else {
            debugPrint("⚠️ Message already exists: ${chatMessage.id}");
          }
        } catch (e) {
          debugPrint("Error processing incoming message: $e");
        }
      });

      debugPrint("✅ Subscribed to chat messages");
    } catch (e) {
      debugPrint("❌ Subscription Error: $e");
    }
  }

  Future<bool> initiateChat({
    required String serviceId,
    required String providerId,
    int retryCount = 0,
  }) async {
    debugPrint("=== INITIATE CHAT STARTED (Attempt ${retryCount + 1}) ===");
    debugPrint("Service ID: $serviceId");
    debugPrint("Provider ID: $providerId");

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('provider_auth_token');

      if (token == null) {
        debugPrint("ERROR: Token not found!");
        _error = 'Authentication token not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (serviceId.isEmpty || providerId.isEmpty) {
        debugPrint("ERROR: Service ID or Provider ID is empty");
        _error = 'Invalid service or provider information';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final requestBody = {
        'service_id': int.tryParse(serviceId) ?? serviceId,
        'user_id': int.tryParse(providerId) ?? providerId,
      };

      debugPrint("Request URL: $base_url/bid/api/chat/provider/initiate");
      debugPrint("Request Body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse('$base_url/bid/api/chat/provider/initiate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      debugPrint("=== API RESPONSE ===");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint("Parsed Response Data: $data");

        if (data['success'] == true && data['chat'] != null) {
          final chatData = data['chat'];
          if (chatData['id'] != null) {
            _chatId = chatData['id'].toString();
          } else if (chatData['chat_id'] != null) {
            _chatId = chatData['chat_id'].toString();
          }

          debugPrint("Chat ID: $_chatId");

          if (_chatId == null || _chatId!.isEmpty) {
            debugPrint("ERROR: Chat ID is empty or null");
            _error = 'Invalid chat ID received';
            _isLoading = false;
            notifyListeners();
            return false;
          }

          bool natsConnected = false;
          try {
            if (!_natsService.isConnected) {
              debugPrint("Initializing NATS connection...");
              natsConnected = await _natsService.connect();
            } else {
              natsConnected = true;
            }
          } catch (e) {
            debugPrint("NATS connection error (non-critical): $e");
            natsConnected = false;
          }

          if (natsConnected) {
            try {
              final historySuccess = await fetchChatHistory(chatId: _chatId!);
              if (historySuccess) {
                await subscribeToMessages(chatId: _chatId!);
              }
            } catch (e) {
              debugPrint("NATS operations error (non-critical): $e");
            }
          } else {
            debugPrint("NATS not available - chat initiated without real-time updates");
          }

          debugPrint("SUCCESS: Chat initiated successfully!");
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          debugPrint("ERROR: Response success is false or chat is null");
          _error = data['message'] ?? 'Failed to initiate chat';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else if (response.statusCode == 500 && retryCount < 2) {
        debugPrint("⚠️ Server error 500 - Retrying after 2 seconds...");
        await Future.delayed(Duration(seconds: 2));
        return await initiateChat(
          serviceId: serviceId,
          providerId: providerId,
          retryCount: retryCount + 1,
        );
      } else {
        debugPrint("ERROR: API returned error status code ${response.statusCode}");
        String errorMessage;

        switch (response.statusCode) {
          case 400:
            errorMessage = 'Invalid request - Please check service details';
            break;
          case 401:
            errorMessage = 'Session expired - Please login again';
            break;
          case 403:
            errorMessage = 'Access denied - You do not have permission';
            break;
          case 404:
            errorMessage = 'Service or provider not found';
            break;
          case 500:
            errorMessage = 'Server error - Please try again later';
            break;
          case 503:
            errorMessage = 'Service temporarily unavailable';
            break;
          default:
            errorMessage = 'Failed to initiate chat';
        }

        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          debugPrint("Could not parse error response");
        }

        _error = errorMessage;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("=== EXCEPTION OCCURRED ===");
      debugPrint("Error: $e");
      debugPrint("Stack Trace: $stackTrace");

      String errorMessage;
      if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout - Please check your connection';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid server response';
      } else {
        errorMessage = 'Connection error - Please try again';
      }

      _error = errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Send message
  Future<bool> sendMessage({required String message}) async {
    if (_chatId == null) {
      debugPrint("ERROR: Cannot send message, chatId is null");
      _error = 'Chat not initialized';
      notifyListeners();
      return false;
    }

    debugPrint("=== SEND MESSAGE STARTED ===");
    debugPrint("Chat ID: $_chatId");
    debugPrint("Message: $message");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('provider_auth_token');

      if (token == null) {
        debugPrint("ERROR: Token not found!");
        _error = 'Authentication token not found';
        notifyListeners();
        return false;
      }

      final requestBody = {'chat_id': _chatId, 'message': message};

      debugPrint("Request URL: $base_url/bid/api/chat/provider/send-message");
      debugPrint("Request Body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse('$base_url/bid/api/chat/provider/send-message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint("=== SEND MESSAGE RESPONSE ===");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint("Message sent successfully!");

        try {
          if (data['message'] != null) {
            final chatMessage = ChatMessage.fromJson(data['message']);

            bool exists = _messages.any((m) => m.id == chatMessage.id);
            if (!exists) {
              _messages.add(chatMessage);
              _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
              debugPrint("Message added to local list: ${chatMessage.id}");
              notifyListeners();
            } else {
              debugPrint("⚠️ Message already exists: ${chatMessage.id}");
            }
          }
        } catch (e) {
          debugPrint("Error parsing message: $e");
        }

        return true;
      } else {
        debugPrint("ERROR: Failed to send message");
        try {
          final errorData = jsonDecode(response.body);
          _error = errorData['message'] ?? 'Failed to send message';
        } catch (e) {
          _error = 'Failed to send message (Status: ${response.statusCode})';
        }
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("=== EXCEPTION in sendMessage ===");
      debugPrint("Error: $e");
      debugPrint("Stack Trace: $stackTrace");
      _error = 'Network error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _error = null;
    _chatId = null;
    _messages = [];

    if (_chatSubscription != null && _chatId != null) {
      _natsService.unsubscribe('chat.message.$_chatId');
      _chatSubscription = null;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    if (_chatSubscription != null && _chatId != null) {
      _natsService.unsubscribe('chat.message.$_chatId');
    }
    super.dispose();
  }
}

// Chat message model
class ChatMessage {
  final String id;
  final String message;
  final String chatId;
  final String senderId;
  final String senderType;
  final bool isRead;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.message,
    required this.chatId,
    required this.senderId,
    required this.senderType,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    debugPrint("=== Parsing ChatMessage ===");
    debugPrint("Raw JSON: $json");

    // Parse ID - handle both direct int and nested structure
    String messageId = '';
    if (json['id'] != null) {
      if (json['id'] is Map) {
        messageId = json['id']['id']?.toString() ?? '';
      } else {
        messageId = json['id'].toString();
      }
    }
    debugPrint("Parsed ID: $messageId");

    // Parse message - handle both direct string and nested object with 'text' field
    String messageText = '';
    if (json['message'] != null) {
      if (json['message'] is Map) {
        // Handle {"message": {"text": "hello"}} structure
        messageText = json['message']['text']?.toString() ?? '';
      } else if (json['message'] is String) {
        // Handle direct string
        messageText = json['message'];
      }
    }
    debugPrint("Parsed Message: $messageText");

    // Parse other fields
    final chatId = json['chat_id']?.toString() ?? '';
    final senderId = json['sender_id']?.toString() ?? '';
    final senderType = json['sender_type']?.toString().toLowerCase() ?? '';
    final isRead = json['is_read'] == true;

    DateTime createdAt;
    try {
      if (json['created_at'] != null) {
        createdAt = DateTime.parse(json['created_at']);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      debugPrint("Error parsing date: $e");
      createdAt = DateTime.now();
    }

    debugPrint("Created ChatMessage successfully");
    debugPrint("Sender Type: $senderType");

    return ChatMessage(
      id: messageId,
      message: messageText,
      chatId: chatId,
      senderId: senderId,
      senderType: senderType,
      isRead: isRead,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'chat_id': chatId,
      'sender_id': senderId,
      'sender_type': senderType,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}