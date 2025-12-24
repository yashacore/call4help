import 'package:flutter/material.dart';
import '../screens/commonOnboarding/splashScreen/splash_screen.dart';
import '../screens/commonOnboarding/loginScreen/login_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
  };
}
