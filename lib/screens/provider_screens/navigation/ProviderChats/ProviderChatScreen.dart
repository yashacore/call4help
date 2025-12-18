import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../../../constants/colorConstant/color_constant.dart';
import 'ProviderChatProvider.dart';

class ProviderChatScreen extends StatefulWidget {
  final String? userName;
  final String? userImage;
  final String? userId;
  final bool isOnline;
  final String? userPhone;
  final String? serviceId;
  final String? providerId;

  const ProviderChatScreen({
    super.key,
    this.userName = "User Name",
    this.userImage,
    this.userId,
    this.isOnline = false,
    this.userPhone,
    this.serviceId,
    this.providerId,
  });

  @override
  State<ProviderChatScreen> createState() => _ProviderChatScreenState();
}

class _ProviderChatScreenState extends State<ProviderChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isTyping = false;
  bool _chatInitialized = false;
  bool _isSending = false;
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    debugPrint("=== ProviderChatScreen initState ===");
    debugPrint("Service ID: ${widget.serviceId}");
    debugPrint("Provider ID: ${widget.providerId}");
    debugPrint("User Name: ${widget.userName}");

    _messageController.addListener(_onTextChanged);

    // Listen to keyboard changes
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 600), () {
          _scrollToBottom();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("PostFrameCallback - calling _initializeChat");
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    debugPrint("=== _initializeChat called ===");
    debugPrint("serviceId is null: ${widget.serviceId == null}");
    debugPrint("providerId is null: ${widget.providerId == null}");

    if (widget.serviceId == null || widget.providerId == null) {
      debugPrint("ERROR: serviceId or providerId is null!");
      debugPrint("serviceId: ${widget.serviceId}");
      debugPrint("providerId: ${widget.providerId}");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Missing service or provider information'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'GO BACK',
              textColor: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        );
      }
      return;
    }

    try {
      final chatProvider = Provider.of<ProviderChatProvider>(
        context,
        listen: false,
      );
      debugPrint("ChatProvider obtained successfully");

      debugPrint("Calling chatProvider.initiateChat...");
      final success = await chatProvider.initiateChat(
        serviceId: widget.serviceId!,
        providerId: widget.providerId!,
      );

      debugPrint("initiateChat returned: $success");

      if (success) {
        setState(() {
          _chatInitialized = true;
          _previousMessageCount = chatProvider.messages.length;
        });

        // Wait for build to complete, then scroll
        await Future.delayed(Duration(milliseconds: 300));
        _scrollToBottom(immediate: true);
      } else {
        debugPrint("Chat initialization failed");
        if (mounted && chatProvider.error != null) {
          debugPrint("Error: ${chatProvider.error}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(chatProvider.error!),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: 'RETRY',
                textColor: Colors.white,
                onPressed: () => _initializeChat(),
              ),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint("=== EXCEPTION in _initializeChat ===");
      debugPrint("Error: $e");
      debugPrint("StackTrace: $stackTrace");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize chat'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: () => _initializeChat(),
            ),
          ),
        );
      }
    }
  }

  void _onTextChanged() {
    setState(() {
      _isTyping = _messageController.text.trim().isNotEmpty;
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    if (!_chatInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please wait for chat to initialize'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final messageText = _messageController.text.trim();

    setState(() {
      _messageController.clear();
      _isSending = true;
      _isTyping = false;
    });

    try {
      final chatProvider = Provider.of<ProviderChatProvider>(
        context,
        listen: false,
      );

      final success = await chatProvider.sendMessage(message: messageText);

      setState(() {
        _isSending = false;
      });

      if (success) {
        // Wait for the UI to update with the new message
        await Future.delayed(Duration(milliseconds: 100));
        _scrollToBottom(immediate: true);

        // Backup scroll attempt
        await Future.delayed(Duration(milliseconds: 400));
        _scrollToBottom(immediate: true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(chatProvider.error ?? 'Failed to send message'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
              action: SnackBarAction(
                label: 'RETRY',
                textColor: Colors.white,
                onPressed: () {
                  _messageController.text = messageText;
                  _sendMessage();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error sending message: $e");
      setState(() {
        _isSending = false;
      });
    }
  }

  void _scrollToBottom({bool immediate = false}) {
    if (!_scrollController.hasClients) return;

    if (immediate) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    } else {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldGray,
      appBar: _buildAppBar(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Consumer<ProviderChatProvider>(
          builder: (context, chatProvider, child) {
            // Check if new message was added
            if (chatProvider.messages.length > _previousMessageCount) {
              _previousMessageCount = chatProvider.messages.length;
              // Scroll to bottom when new message arrives
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Future.delayed(Duration(milliseconds: 200), () {
                  _scrollToBottom(immediate: true);
                });
              });
            }

            if (chatProvider.isLoading && !_chatInitialized) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: ColorConstant.call4hepOrange),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading chat...',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Color(0xFF7A7A7A),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: chatProvider.messages.isEmpty
                      ? _buildEmptyState()
                      : _buildMessagesList(chatProvider),
                ),
                _buildMessageInput(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64.sp,
            color: Color(0xFFE0E0E0),
          ),
          SizedBox(height: 16.h),
          Text(
            'No messages yet',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              color: Color(0xFF7A7A7A),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start the conversation!',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Color(0xFFB0B0B0),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withAlpha(1),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFF1D1B20)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ColorConstant.call4hepOrange.withAlpha(1),
                    width: 2.w,
                  ),
                ),
                child: ClipOval(
                  child: widget.userImage != null
                      ? CachedNetworkImage(
                          imageUrl: widget.userImage!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: ColorConstant.call4hepOrangeFade,
                            child: Icon(
                              Icons.person,
                              color: ColorConstant.call4hepOrange,
                              size: 20.sp,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: ColorConstant.call4hepOrangeFade,
                            child: Icon(
                              Icons.person,
                              color: ColorConstant.call4hepOrange,
                              size: 20.sp,
                            ),
                          ),
                        )
                      : Container(
                          color: ColorConstant.call4hepOrangeFade,
                          child: Icon(
                            Icons.person,
                            color: ColorConstant.call4hepOrange,
                            size: 20.sp,
                          ),
                        ),
                ),
              ),
              if (widget.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: ColorConstant.call4hepGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.w),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName ?? "User Name",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1B20),
                  ),
                ),
                if (widget.isOnline)
                  Text(
                    'Online',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: ColorConstant.call4hepGreen,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: Color(0xFF1D1B20)),
          onPressed: () {
            // Show options menu
          },
        ),
      ],
    );
  }

  Widget _buildMessagesList(ProviderChatProvider chatProvider) {
    // Sort messages to ensure correct order (oldest first)
    final sortedMessages = List<ChatMessage>.from(chatProvider.messages)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: sortedMessages.length,
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final message = sortedMessages[index];
        final showDate =
            index == 0 ||
            !_isSameDay(message.createdAt, sortedMessages[index - 1].createdAt);

        final isSentByMe = message.senderType.toLowerCase() == 'provider';

        return Column(
          children: [
            if (showDate) _buildDateDivider(message.createdAt),
            _buildMessageBubble(message, isSentByMe),
            SizedBox(height: 8.h),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    String dateText;

    if (difference == 0) {
      dateText = 'Today';
    } else if (difference == 1) {
      dateText = 'Yesterday';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Expanded(child: Divider(color: Color(0xFFE6E6E6))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              dateText,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Color(0xFF7A7A7A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Color(0xFFE6E6E6))),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isSentByMe) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSentByMe) ...[
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorConstant.call4hepOrangeFade,
              ),
              child: Icon(
                Icons.person,
                size: 16.sp,
                color: ColorConstant.call4hepOrange,
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 280.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isSentByMe ? ColorConstant.call4hepOrange : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(isSentByMe ? 16.r : 4.r),
                  bottomRight: Radius.circular(isSentByMe ? 4.r : 16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: isSentByMe ? Colors.white : Color(0xFF1D1B20),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: isSentByMe
                              ? Colors.white.withAlpha(8)
                              : Color(0xFF7A7A7A),
                        ),
                      ),
                      if (isSentByMe) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.check,
                          size: 14.sp,
                          color: message.isRead
                              ? ColorConstant.call4hepGreen
                              : Colors.white.withAlpha(8),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isSentByMe) SizedBox(width: 8.w),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                enabled: _chatInitialized && !_isSending,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Color(0xFF1D1B20),
                ),
                decoration: InputDecoration(
                  hintText: _chatInitialized
                      ? 'Type a message...'
                      : 'Loading chat...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Color(0xFF7A7A7A),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          InkWell(
            onTap: (_isTyping && _chatInitialized && !_isSending)
                ? _sendMessage
                : null,
            borderRadius: BorderRadius.circular(25.r),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: (_isTyping && _chatInitialized && !_isSending)
                    ? ColorConstant.call4hepOrange
                    : ColorConstant.call4hepOrangeFade,
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      Icons.send,
                      color: (_isTyping && _chatInitialized)
                          ? Colors.white
                          : ColorConstant.call4hepOrange,
                      size: 20.sp,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
