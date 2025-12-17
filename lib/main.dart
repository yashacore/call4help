import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:first_flutter/providers/provider_navigation_provider.dart';
import 'package:first_flutter/providers/user_navigation_provider.dart';
import 'package:first_flutter/screens/Skills/MySkillProvider.dart';
import 'package:first_flutter/screens/SubCategory/SkillProvider.dart';
import 'package:first_flutter/screens/SubCategory/SubcategoryProvider.dart';
import 'package:first_flutter/screens/commonOnboarding/otpScreen/otp_screen_provider.dart';
import 'package:first_flutter/screens/provider_screens/LegalDocumentScreen.dart';
import 'package:first_flutter/screens/provider_screens/ProviderProfile/EditProviderProfileProvider.dart';
import 'package:first_flutter/screens/provider_screens/ProviderProfile/EditProviderProfileScreen.dart';
import 'package:first_flutter/screens/provider_screens/ProviderProfile/ProviderOnboardingScreen.dart';
import 'package:first_flutter/screens/provider_screens/ProviderProfile/ProviderProfileProvider.dart';
import 'package:first_flutter/screens/provider_screens/ProviderProfile/ProviderProfileScreen.dart';
import 'package:first_flutter/screens/provider_screens/ServiceArrivalProvider.dart';
import 'package:first_flutter/screens/provider_screens/SettingsProvider.dart';
import 'package:first_flutter/screens/provider_screens/StartWorkProvider.dart';
import 'package:first_flutter/screens/provider_screens/navigation/AvailabilityProvider.dart';
import 'package:first_flutter/screens/provider_screens/navigation/EarningsProvider.dart';
import 'package:first_flutter/screens/provider_screens/navigation/NotificationProvider.dart';
import 'package:first_flutter/screens/provider_screens/navigation/ProviderChats/ProviderChatProvider.dart';
import 'package:first_flutter/screens/provider_screens/navigation/UserNotificationProvider.dart';
import 'package:first_flutter/screens/provider_screens/navigation/provider_service_tab_body/ProviderBidProvider.dart';
import 'package:first_flutter/screens/provider_screens/navigation/provider_service_tab_body/provider_confirmed_service.dart';
import 'package:first_flutter/screens/provider_screens/provider_custom_bottom_nav.dart';
import 'package:first_flutter/screens/provider_screens/provider_service_details_screen.dart';
import 'package:first_flutter/screens/user_screens/Address/MyAddressProvider.dart';
import 'package:first_flutter/screens/user_screens/BookProviderProvider.dart';
import 'package:first_flutter/screens/user_screens/Home/CategoryProvider.dart';
import 'package:first_flutter/screens/user_screens/Profile/EditProfileProvider.dart';
import 'package:first_flutter/screens/user_screens/Profile/EditProfileScreen.dart';
import 'package:first_flutter/screens/user_screens/Profile/FAQProvider.dart';
import 'package:first_flutter/screens/user_screens/Profile/UserProfileProvider.dart';
import 'package:first_flutter/screens/user_screens/SubCategory/SubCategoryProvider.dart';
import 'package:first_flutter/screens/user_screens/SubCategory/SubCategoryStateProvider.dart';
import 'package:first_flutter/screens/user_screens/SubCategory/sub_cat_of_cat_screen.dart';
import 'package:first_flutter/screens/user_screens/User Instant Service/UserInstantServiceProvider.dart';
import 'package:first_flutter/screens/user_screens/navigation/EmergencyContactProvider.dart';
import 'package:first_flutter/screens/user_screens/navigation/SOSProvider.dart';
import 'package:first_flutter/screens/user_screens/navigation/UserChats/UserChatProvider.dart';
import 'package:first_flutter/screens/user_screens/navigation/UserSOSProvider.dart';
import 'package:first_flutter/screens/user_screens/navigation/user_service_tab_body/ServiceProvider.dart';
import 'package:first_flutter/screens/user_screens/navigation/user_service_tab_body/UserCompletedServiceProvider.dart';
import 'package:first_flutter/screens/user_screens/user_custom_bottom_nav.dart';
import 'package:first_flutter/screens/user_screens/User Instant Service/user_instant_service_screen.dart';
import 'package:first_flutter/screens/user_screens/Profile/user_profile_screen.dart';
import 'package:first_flutter/screens/user_screens/user_service_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'BannerModel.dart';
import 'NATS Service/NatsService.dart';
import 'NotificationService.dart';
import 'screens/commonOnboarding/loginScreen/login_screen.dart';
import 'screens/commonOnboarding/loginScreen/login_screen_provider.dart';
import 'screens/commonOnboarding/splashScreen/splash_screen.dart';
import 'screens/commonOnboarding/splashScreen/splash_screen_provider.dart';

/// ================== BACKGROUND FCM HANDLER ==================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint("🔔 BACKGROUND MESSAGE");
  debugPrint("Title: ${message.notification?.title}");
  debugPrint("Body: ${message.notification?.body}");
}

/// ================== MAIN ==================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint("🚀 App Starting");

  try {
    /// NATS
    await NatsService().initialize(
      url: 'nats://api.moyointernational.com',
      autoReconnect: true,
      reconnectInterval: const Duration(seconds: 5),
    );

    /// FCM Background Handler (REGISTER ONCE)
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    /// Notifications
    await NotificationService.initializeNotifications();
    NotificationService.setupTokenRefreshListener();
  } catch (e) {
    debugPrint("❌ INIT ERROR: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => OtpScreenProvider()),
        ChangeNotifierProvider(create: (_) => UserNavigationProvider()),
        ChangeNotifierProvider(create: (_) => ProviderNavigationProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => SubcategoryProvider()),
        ChangeNotifierProvider(create: (_) => SkillProvider()),
        ChangeNotifierProvider(create: (_) => MySkillProvider()),
        ChangeNotifierProvider(create: (_) => CarouselProvider()),
        ChangeNotifierProvider(create: (_) => SubCategoryProvider()),
        ChangeNotifierProvider(create: (_) => ServiceFormFieldProvider()),
        ChangeNotifierProvider(create: (_) => ProviderProfileProvider()),
        ChangeNotifierProvider(create: (_) => EditProfileProvider()),
        ChangeNotifierProvider(create: (_) => UserInstantServiceProvider()),
        ChangeNotifierProvider(create: (_) => MyAddressProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => EditProviderProfileProvider()),
        ChangeNotifierProvider(create: (_) => ProviderBidProvider()),
        ChangeNotifierProvider(create: (_) => BookProviderProvider()),
        ChangeNotifierProvider(create: (_) => ProviderServiceProvider()),
        ChangeNotifierProvider(create: (_) => ServiceArrivalProvider()),
        ChangeNotifierProvider(create: (_) => StartWorkProvider()),
        ChangeNotifierProvider(create: (_) => FAQProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserNotificationProvider()),
        ChangeNotifierProvider(create: (_) => LegalDocumentProvider()),
        ChangeNotifierProvider(create: (_) => CompletedServiceProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => EarningsProvider()),
        ChangeNotifierProvider(create: (_) => AvailabilityProvider()),
        ChangeNotifierProvider(create: (_) => UserChatProvider()),
        ChangeNotifierProvider(create: (_) => ProviderChatProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyContactProvider()),
        ChangeNotifierProvider(create: (_) => SOSProvider()),
        ChangeNotifierProvider(create: (_) => UserSOSProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// ================== APP ==================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      builder: (_, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: NotificationService.navigatorKey,
        theme: ThemeData(
          textTheme: GoogleFonts.interTextTheme(),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/UserCustomBottomNav': (_) => const UserCustomBottomNav(),
          '/UserServiceDetailsScreen': (_) =>
          const UserServiceDetailsScreen(),
          '/editProfile': (_) => const EditProfileScreen(),
          '/ProviderCustomBottomNav': (_) =>
          const ProviderCustomBottomNav(),
          '/UserProfileScreen': (_) => const UserProfileScreen(),
          '/SubCatOfCatScreen': (_) => const SubCatOfCatScreen(),
          '/providerProfile': (_) => ProviderProfileScreen(),
          '/editProviderProfile': (_) => EditProviderProfileScreen(),
          '/ProviderOnboarding': (_) => const ProviderOnboardingDialog(),
          '/UserInstantServiceScreen': (_) =>
          const UserInstantServiceScreen(
            categoryId: 1,
            serviceType: '',
          ),
        },
      ),
    );
  }
}
