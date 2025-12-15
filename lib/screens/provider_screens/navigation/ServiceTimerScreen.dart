import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:first_flutter/screens/user_screens/navigation/SOSEmergencyScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../NATS Service/NatsService.dart';

class ServiceTimerScreen extends StatefulWidget {
  final String serviceId;
  final int durationValue;
  final String durationUnit;
  final String? categoryName;  // Made nullable
  final String? subCategoryName;  // Made nullable

  ServiceTimerScreen({
    super.key,
    required this.serviceId,
    required this.durationValue,
    required this.durationUnit,
    this.categoryName,
    this.subCategoryName,
  });

  @override
  State<ServiceTimerScreen> createState() => _ServiceTimerScreenState();
}

class _ServiceTimerScreenState extends State<ServiceTimerScreen> {
  final NatsService _natsService = NatsService();
  Timer? _timer;
  Timer? _apiTimer;

  int _totalSeconds = 0;
  int _elapsedSeconds = 0;
  int _allocatedSeconds = 0;
  bool _isExtraTime = false;
  bool _isLoading = true;

  Map<String, dynamic>? _serviceData;

  // OTP Controllers
  final List<TextEditingController> _startOtpControllers = List.generate(
    5,
        (_) => TextEditingController(),
  );
  final List<FocusNode> _startOtpFocusNodes = List.generate(
    5,
        (_) => FocusNode(),
  );

  final List<TextEditingController> _satisfactionCodeControllers =
  List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _satisfactionCodeFocusNodes = List.generate(
    5,
        (_) => FocusNode(),
  );

  String? _startTime;
  String? _endTime;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    _fetchServiceDetails();

    // Start periodic API calls every 10 seconds
    _apiTimer = Timer.periodic(
      const Duration(seconds: 10),
          (timer) => _fetchServiceDetails(),
    );
  }

  void _initializeTimer() {
    // Convert duration to seconds
    _allocatedSeconds = widget.durationValue * 3600;
    _totalSeconds = _allocatedSeconds;

    // Load saved timer state if exists
    _loadTimerState();

    // Start the countdown timer
    _startTimer();
  }

  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedElapsed = prefs.getInt('timer_elapsed_${widget.serviceId}');
    final savedStartTime = prefs.getString('timer_start_${widget.serviceId}');

    if (savedElapsed != null && savedStartTime != null) {
      final startTime = DateTime.parse(savedStartTime);
      final now = DateTime.now();
      final actualElapsed = now.difference(startTime).inSeconds;

      setState(() {
        _elapsedSeconds = actualElapsed;
        _startTime = savedStartTime;
        _checkExtraTime();
      });
    } else {
      // First time - save start time
      final now = DateTime.now().toIso8601String();
      await prefs.setString('timer_start_${widget.serviceId}', now);
      setState(() {
        _startTime = now;
      });
    }
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timer_elapsed_${widget.serviceId}', _elapsedSeconds);
    if (_startTime != null) {
      await prefs.setString('timer_start_${widget.serviceId}', _startTime!);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        _checkExtraTime();
      });
      _saveTimerState();
    });
  }

  void _checkExtraTime() {
    if (_elapsedSeconds > _allocatedSeconds) {
      _isExtraTime = true;
    }
  }

  Future<void> _fetchServiceDetails() async {
    try {
      if (!_natsService.isConnected) {
        await _natsService.connect(
          url: 'nats://api.moyointernational.com:4222',
        );
      }

      final requestData = jsonEncode({'service_id': widget.serviceId});

      print('📞 Requesting "service.info.details": $requestData');

      final response = await _natsService.request(
        'service.info.details',
        requestData,
        timeout: const Duration(seconds: 5),
      );

      if (response != null) {
        final data = jsonDecode(response);
        print('📨 Response received: ${jsonEncode(data)}');

        setState(() {
          _serviceData = data;
          _isLoading = false;
        });

        // Check if service has ended
        if (data['status'] == 'completed' || data['status'] == 'ended') {
          _stopTimer();
        }
      }
    } catch (e) {
      print('Error fetching service details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _apiTimer?.cancel();
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    return _isExtraTime
        ? Colors.red
        : const Color(0xFF4CAF50); // Green for normal, Red for extra
  }

  Widget _buildOTPField(
      List<TextEditingController> controllers,
      List<FocusNode> focusNodes,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          width: 50.w,
          height: 50.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF9800),
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: const Color(0xFFFF9800),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: const Color(0xFFFF9800).withOpacity(0.5),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: const Color(0xFFFF9800),
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 4) {
                focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                focusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  Future<void> _handleSOS() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SOSEmergencyScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _apiTimer?.cancel();

    for (var controller in _startOtpControllers) {
      controller.dispose();
    }
    for (var node in _startOtpFocusNodes) {
      node.dispose();
    }
    for (var controller in _satisfactionCodeControllers) {
      controller.dispose();
    }
    for (var node in _satisfactionCodeFocusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provide default values for nullable fields
    final categoryName = widget.categoryName ?? 'Service';
    final subCategoryName = widget.subCategoryName ?? 'Category';

    return Scaffold(
      backgroundColor: const Color(0xFFFF9800),
      body: Column(
        children: [
          // Top section with service provider image
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                // Background image with overlay
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        _serviceData?['user']?['image'] as String? ??
                            'https://picsum.photos/400/300',
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),

                // Moyo logo
                Positioned(
                  top: 20.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'moyo',
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

                // Service category
                Positioned(
                  bottom: 20.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                        Text(
                          subCategoryName,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom section with timer and controls
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 80.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(30.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Column(
                  children: [
                    // Service category text
                    Text(
                      '$categoryName > $subCategoryName',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    Divider(thickness: 1, color: Colors.grey.shade300),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timer Clock
                        Expanded(
                          flex: 5,
                          child: CustomPaint(
                            size: Size(180.w, 180.w),
                            painter: TimerClockPainter(
                              elapsedSeconds: _elapsedSeconds,
                              allocatedSeconds: _allocatedSeconds,
                              color: _getTimerColor(),
                              isExtraTime: _isExtraTime,
                            ),
                            child: Container(
                              width: 180.w,
                              height: 180.w,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 14.w),

                        // OTP and Service Time section
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20.h),
                              // Elapsed Time Display
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _isExtraTime
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                                  border: Border.all(
                                    color: _isExtraTime
                                        ? Colors.red
                                        : const Color(0xFF4CAF50),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isExtraTime
                                          ? 'Extra Time'
                                          : 'Elapsed Time',
                                      style: TextStyle(
                                        fontSize: 8.sp,
                                        color: _isExtraTime
                                            ? Colors.red
                                            : const Color(0xFF4CAF50),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      _formatTime(
                                        _isExtraTime
                                            ? _elapsedSeconds -
                                            _allocatedSeconds
                                            : _elapsedSeconds,
                                      ),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: _isExtraTime
                                            ? Colors.red
                                            : const Color(0xFF4CAF50),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFFF9800),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Service Time',
                                      style: TextStyle(
                                        fontSize: 8.sp,
                                        color: const Color(0xFFFF9800),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      (_serviceData?['schedule_time'] as String?) ?? '12:00 PM - 06:00 PM',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: const Color(0xFFFF9800),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 15.w),
                        GestureDetector(
                          onTap: _handleSOS,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Cancellation',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        GestureDetector(
                          onTap: _handleSOS,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Timer Clock
class TimerClockPainter extends CustomPainter {
  final int elapsedSeconds;
  final int allocatedSeconds;
  final Color color;
  final bool isExtraTime;

  TimerClockPainter({
    required this.elapsedSeconds,
    required this.allocatedSeconds,
    required this.color,
    required this.isExtraTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Calculate progress percentage
    final progressSeconds = isExtraTime ? allocatedSeconds : elapsedSeconds;
    final totalForProgress = isExtraTime ? allocatedSeconds : allocatedSeconds;
    final progressPercentage = progressSeconds / totalForProgress;
    final progressAngle = progressPercentage * 2 * pi;

    // Draw clock face background (beige color for remaining time)
    final bgPaint = Paint()
      ..color = const Color(0xFFFFF3E0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw green filled arc for elapsed time (like a pie slice)
    if (!isExtraTime && elapsedSeconds > 0) {
      final greenPaint = Paint()
        ..color =
        const Color(0xFF8BC34A) // Light green color
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(center.dx, center.dy); // Start from center
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        progressAngle,
        false,
      );
      path.lineTo(center.dx, center.dy); // Back to center
      path.close();

      canvas.drawPath(path, greenPaint);
    }

    // If in extra time, fill entire clock with red and show extra progress in darker red
    if (isExtraTime) {
      // First fill entire clock with light red
      final redBgPaint = Paint()
        ..color =
        const Color(0xFFFFF3E0) // Light red
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, redBgPaint);

      // Then draw darker red for extra elapsed time
      final extraSeconds = elapsedSeconds - allocatedSeconds;
      final extraPercentage =
          (extraSeconds % allocatedSeconds) / allocatedSeconds;
      final extraAngle = extraPercentage * 2 * pi;

      if (extraSeconds > 0) {
        final darkRedPaint = Paint()
          ..color =
          const Color(0xFFFF5252) // Darker red
          ..style = PaintingStyle.fill;

        final path = Path();
        path.moveTo(center.dx, center.dy);
        path.arcTo(
          Rect.fromCircle(center: center, radius: radius),
          -pi / 2,
          extraAngle,
          false,
        );
        path.lineTo(center.dx, center.dy);
        path.close();

        canvas.drawPath(path, darkRedPaint);
      }
    }

    // Draw outer circle border (orange)
    final circlePaint = Paint()
      ..color =
      const Color(0xFFFF9800) // Orange border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius - 4, circlePaint);

    // Draw hour markers (numbers)
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * (pi / 180);
      final x1 = center.dx + (radius - 20) * cos(angle - pi / 2);
      final y1 = center.dy + (radius - 20) * sin(angle - pi / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: i == 0 ? '12' : i.toString(),
          style: TextStyle(
            color: const Color(0xFFFF9800),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x1 - textPainter.width / 2, y1 - textPainter.height / 2),
      );
    }

    // Calculate hour and minute angles
    final totalMinutes = elapsedSeconds / 60;
    final hours = (totalMinutes / 60) % 12;
    final minutes = totalMinutes % 60;

    // Hour hand angle (30 degrees per hour + 0.5 degrees per minute)
    final hourAngle = (hours * 30 + minutes * 0.5) * (pi / 180) - pi / 2;

    // Minute hand angle (6 degrees per minute)
    final minuteAngle = (minutes * 6) * (pi / 180) - pi / 2;

    // Draw hour hand (shorter and thicker) - Orange color
    final hourHandPaint = Paint()
      ..color =
      const Color(0xFFFF9800) // Orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final hourHandLength = radius - 50;
    final hourHandX = center.dx + hourHandLength * cos(hourAngle);
    final hourHandY = center.dy + hourHandLength * sin(hourAngle);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandPaint);

    // Draw minute hand (longer and thinner) - Orange color
    final minuteHandPaint = Paint()
      ..color =
      const Color(0xFFFF9800) // Orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final minuteHandLength = radius - 30;
    final minuteHandX = center.dx + minuteHandLength * cos(minuteAngle);
    final minuteHandY = center.dy + minuteHandLength * sin(minuteAngle);
    canvas.drawLine(center, Offset(minuteHandX, minuteHandY), minuteHandPaint);

    // Draw center dot - Orange color
    final dotPaint = Paint()
      ..color =
      const Color(0xFFFF9800) // Orange
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, dotPaint);
  }

  @override
  bool shouldRepaint(TimerClockPainter oldDelegate) {
    return oldDelegate.elapsedSeconds != elapsedSeconds ||
        oldDelegate.color != color ||
        oldDelegate.isExtraTime != isExtraTime;
  }
}