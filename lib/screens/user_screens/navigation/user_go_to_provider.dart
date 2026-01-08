import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config/baseControllers/APis.dart';
import '../../../providers/provider_navigation_provider.dart';

enum Mode { customer, provider }

class UserGoToProvider extends StatefulWidget {
  const UserGoToProvider({super.key});

  @override
  State<UserGoToProvider> createState() => _UserGoToProviderState();
}

class _UserGoToProviderState extends State<UserGoToProvider> {
  bool _isLoading = false;

  Future<void> updateProviderFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('provider_auth_token');
      final FirebaseMessaging _firebaseMessaging =
          FirebaseMessaging.instance;
      final fcmToken = await _firebaseMessaging.getToken();


      if (authToken == null || authToken.isEmpty) {
        throw Exception('User auth token not found');
      }

      final url =
      Uri.parse('https://api.call4help.in/cyber/api/fcm/provider/token');

      final body = {
        "token": fcmToken,
        "device_type": "android",
      };

      debugPrint('📤 FCM TOKEN API URL: $url');
      debugPrint('📤 Request Body: ${jsonEncode(body)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(body),
      );

      debugPrint('📡 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          debugPrint('✅Provider FCM Token updated: ${decoded['message']}');
        } else {
          debugPrint('✅Provider FCM Token updated successfully');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception(
          'Failed to update FCM token (${response.statusCode})',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating FCM token: $e');
      debugPrint('❌ StackTrace: $stackTrace');
    }
  }

  Future<void> _switchToProviderMode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null || authToken.isEmpty) {
        _showErrorDialog('Authentication token not found. Please login again.');
        return;
      }

      final response = await http.post(
        Uri.parse('$base_url/api/provider/switch'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        final providerToken = responseData['providertoken'];
        final providerId = responseData['provider']?['id'];
        final isRegistered =
            responseData['provider']?['isregistered'] ?? false;

        if (providerToken == null || providerToken.isEmpty) {
          _showErrorDialog('Invalid provider token received.');
          return;
        }

        /// ✅ SAVE PROVIDER SESSION
        await prefs.setString('provider_auth_token', providerToken);
        await prefs.setString('user_role', 'provider');

        if (providerId != null) {
          await prefs.setInt('provider_id', providerId);
        }

        await prefs.setBool('is_provider_registered', isRegistered);

        debugPrint('✅ Switched to provider mode');
        debugPrint('Provider token saved');

        /// 🔥 SAVE PROVIDER FCM TOKEN (IMPORTANT)
        await updateProviderFcmToken();

        /// ➜ NAVIGATE
        if (mounted) {
          Navigator.pushNamed(context, "/ProviderCustomBottomNav");
          context.read<ProviderNavigationProvider>().currentIndex = 0;
        }
      } else {
        final errorData = json.decode(response.body);
        _showErrorDialog(
          errorData['message'] ?? 'Failed to switch role. Please try again.',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error switching to provider mode: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      _showErrorDialog('An error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            SvgPicture.asset('assets/icons/switch_role.svg'),
                            Text(
                              "Switch Role",
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),

                        // Logout Button
                      ],
                    ),
                    _text1(context),
                    Column(
                      spacing: 40,
                      children: [
                        _customerProvider(context),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            SizedBox(
                              width: 200,
                              child: _cancelSwitchButton(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha:0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _text1(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Text(
        "Would you like to switch to Provider mode?",
        textAlign: TextAlign.center,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: const Color(0xFF7A7A7A),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _customerProvider(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      children: [
        Expanded(child: _switchModeContainer(context, Mode.customer, true)),
        Expanded(child: _switchModeContainer(context, Mode.provider, false)),
      ],
    );
  }

  Widget _switchModeContainer(BuildContext context, Enum mode, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: isActive
            ? ColorConstant.call4helpOrangeFade
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? ColorConstant.call4helpOrange : const Color(0xFF7B7B7B),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 6,
        children: [
          isActive && mode == Mode.customer
              ? SvgPicture.asset("assets/icons/customer_mode_active.svg")
              : isActive && mode == Mode.provider
              ? SvgPicture.asset("assets/icons/provider_mode_active.svg")
              : isActive == false && mode == Mode.customer
              ? SvgPicture.asset("assets/icons/customer_mode_blur.svg")
              : SvgPicture.asset("assets/icons/provider_mode_blur.svg"),
          Text(
            mode == Mode.customer ? "Customer Mode" : "Provider Mode",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isActive
                  ? ColorConstant.call4helpOrange
                  : const Color(0xFF7B7B7B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            mode == Mode.customer ? "Book services" : "Offer services",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isActive
                  ? ColorConstant.call4helpOrange
                  : const Color(0xFF7B7B7B),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cancelSwitchButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              decoration: BoxDecoration(
                color: _isLoading ? Colors.grey : ColorConstant.call4helpOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: _isLoading ? null : _switchToProviderMode,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Text(
                    "Switch",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
