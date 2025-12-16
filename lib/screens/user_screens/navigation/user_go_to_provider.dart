import 'package:first_flutter/baseControllers/APis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../constants/colorConstant/color_constant.dart';
import '../../../providers/provider_navigation_provider.dart';

enum Mode { customer, provider }

class UserGoToProvider extends StatefulWidget {
  const UserGoToProvider({super.key});

  @override
  State<UserGoToProvider> createState() => _UserGoToProviderState();
}

class _UserGoToProviderState extends State<UserGoToProvider> {
  bool _isLoading = false;

  Future<void> _updateProviderDeviceToken(
    int providerId,
    String deviceToken,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final providerAuthToken = prefs.getString('provider_auth_token');

      if (providerAuthToken == null || providerAuthToken.isEmpty) {
        debugPrint('Provider auth token not found');
        return;
      }

      final response = await http.post(
        Uri.parse('$base_url/api/auth/provider-device-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $providerAuthToken',
        },
        body: json.encode({
          'providerId': providerId.toString(),
          'deviceToken': deviceToken,
        }),
      );

      debugPrint('Device token update response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        debugPrint('Device token update message: ${responseData['message']}');
      } else {
        debugPrint('Failed to update device token: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating provider device token: $e');
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
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Make API call to get provider token
      final response = await http.post(
        Uri.parse('$base_url/api/provider/switch'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      debugPrint('Auth token: $authToken');
      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Extract provider token
        final providerToken = responseData['providertoken'];
        final providerId = responseData['provider']?['id'];
        final isRegistered = responseData['provider']?['isregistered'] ?? false;

        debugPrint('Provider token: $providerToken');
        debugPrint('Provider ID: $providerId');
        debugPrint('Is registered: $isRegistered');

        if (providerToken != null && providerToken.isNotEmpty) {
          await prefs.setString('provider_auth_token', providerToken);

          // Update user role to provider
          await prefs.setString('user_role', 'provider');

          if (providerId != null) {
            await prefs.setInt('provider_id', providerId);
          }

          // Save provider registration status
          await prefs.setBool('is_provider_registered', isRegistered);

          debugPrint('Successfully switched to provider mode');
          debugPrint('Customer token preserved: ${prefs.getString('auth_token')}');
          debugPrint(
            'Provider token saved: ${prefs.getString('provider_auth_token')}',
          );
          debugPrint('User role: ${prefs.getString('user_role')}');

          // Update provider device token if providerId and deviceToken exist
          if (providerId != null) {
            final deviceToken = prefs.getString('device_token');

            if (deviceToken != null && deviceToken.isNotEmpty) {
              debugPrint('Updating provider device token...');
              await _updateProviderDeviceToken(providerId, deviceToken);
            } else {
              debugPrint('Device token not found in SharedPreferences');
            }
          }

          // Navigate to provider screen
          if (mounted) {
            Navigator.pushNamed(context, "/ProviderCustomBottomNav");
            context.read<ProviderNavigationProvider>().currentIndex = 0;
          }
        } else {
          _showErrorDialog('Invalid response from server. Please try again.');
        }
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Failed to switch role. Please try again.';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      debugPrint('Error in _switchToProviderMode: $e');
      _showErrorDialog('An error occurred: ${e.toString()}');
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
            color: Colors.black.withOpacity(0.3),
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
            ? ColorConstant.call4hepOrangeFade
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? ColorConstant.call4hepOrange : const Color(0xFF7B7B7B),
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
                  ? ColorConstant.call4hepOrange
                  : const Color(0xFF7B7B7B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            mode == Mode.customer ? "Book services" : "Offer services",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isActive
                  ? ColorConstant.call4hepOrange
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
                color: _isLoading ? Colors.grey : ColorConstant.call4hepOrange,
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
