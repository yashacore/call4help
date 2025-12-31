import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:first_flutter/data/api_services/provider_confirmed_service.dart';
import 'package:first_flutter/nats_service/nats_service.dart';
import 'package:first_flutter/providers/availability_provider.dart';
import 'package:first_flutter/providers/earnings_provider.dart';
import 'package:first_flutter/providers/edit_provider_profile_provider.dart';
import 'package:first_flutter/providers/landing_screen_provider.dart';
import 'package:first_flutter/providers/my_bookings_user_provider.dart';
import 'package:first_flutter/providers/my_skill_provider.dart';
import 'package:first_flutter/providers/provider_bid_provider.dart';
import 'package:first_flutter/providers/provider_profile_provider.dart';
import 'package:first_flutter/providers/provider_slots_booking_provider.dart';
import 'package:first_flutter/providers/service_arrival_provider.dart';
import 'package:first_flutter/providers/settings_provider.dart';
import 'package:first_flutter/providers/subcategory_provider.dart';
import 'package:first_flutter/providers/booking_details_provider.dart';
import 'package:first_flutter/providers/booking_status_provider.dart';
import 'package:first_flutter/providers/create_time_slot_provider.dart';
import 'package:first_flutter/providers/login_screen_provider.dart';
import 'package:first_flutter/providers/nearby_cafe_provider.dart';
import 'package:first_flutter/providers/otp_screen_provider.dart';
import 'package:first_flutter/providers/provider_navigation_provider.dart';
import 'package:first_flutter/providers/register_cafe_provider.dart';
import 'package:first_flutter/providers/search_cyber_provider.dart';
import 'package:first_flutter/providers/slot_list_provider.dart';
import 'package:first_flutter/providers/splash_screen_provider.dart'
    show SplashProvider;
import 'package:first_flutter/providers/time_slot_provider.dart';
import 'package:first_flutter/providers/user_navigation_provider.dart';
import 'package:first_flutter/providers/user_notification_provider.dart';
import 'package:first_flutter/providers/vendor_bank_provider.dart';
import 'package:first_flutter/providers/vendor_notification_provider.dart';
import 'package:first_flutter/providers/working_hour_provider.dart';
import 'package:first_flutter/screens/provider_screens/legal_document_screen.dart';
import 'package:first_flutter/screens/provider_screens/ProviderProfile/edit_provider_profile_screen.dart';
import 'package:first_flutter/screens/provider_screens/ProviderProfile/provider_onboarding_screen.dart';
import 'package:first_flutter/screens/provider_screens/ProviderProfile/provider_profile_screen.dart';
import 'package:first_flutter/providers/start_work_provider.dart';
import 'package:first_flutter/screens/provider_screens/navigation/NotificationProvider.dart';
import 'package:first_flutter/screens/provider_screens/navigation/ProviderChats/ProviderChatProvider.dart';
import 'package:first_flutter/screens/provider_screens/navigation/UserNotificationProvider.dart';
import 'package:first_flutter/screens/provider_screens/provider_custom_bottom_nav.dart';
import 'package:first_flutter/providers/my_address_provider.dart';
import 'package:first_flutter/providers/book_provider_provider.dart';
import 'package:first_flutter/providers/category_provider.dart';
import 'package:first_flutter/providers/edit_profile_provider.dart';
import 'package:first_flutter/screens/sub_category/SkillProvider.dart';
import 'package:first_flutter/screens/user_screens/Profile/EditProfileScreen.dart';
import 'package:first_flutter/screens/user_screens/Profile/FAQProvider.dart';
import 'package:first_flutter/providers/user_profile_provider.dart';
import 'package:first_flutter/screens/user_screens/SubCategory/SubCategoryProvider.dart';
import 'package:first_flutter/providers/sub_category_state_provider.dart';
import 'package:first_flutter/screens/user_screens/SubCategory/sub_cat_of_cat_screen.dart';
import 'package:first_flutter/providers/user_instant_service_provider.dart';
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'data/models/BannerModel.dart';
import 'data/api_services/notification_service.dart';
import 'providers/booking_cyber_user_provider.dart';
import 'screens/commonOnboarding/loginScreen/login_screen.dart';
import 'screens/commonOnboarding/splashScreen/splash_screen.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.showLocalNotificationStatic(message);
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initLocalNotifications() async {
  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

/// ================== MAIN ==================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificationService.initializeNotifications();
  NotificationService.setupTokenRefreshListener();

  await NatsService().initialize(
    url: 'nats://api.call4help.in:4222',
    autoReconnect: true,
    reconnectInterval: const Duration(seconds: 5),
  );

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
        ChangeNotifierProvider(create: (_) => SlotProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProviderUser()),
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
        ChangeNotifierProvider(create: (_) => CyberCafeProvider()),
        ChangeNotifierProvider(create: (_) => RegisterCafeProvider()),
        ChangeNotifierProvider(create: (_) => CreateSlotProvider()),
        ChangeNotifierProvider(create: (_) => SlotListProvider()),
        ChangeNotifierProvider(create: (_) => ProviderCafeProvider()),
        ChangeNotifierProvider(create: (_) => ProviderSlotsStatusProvider()),
        ChangeNotifierProvider(create: (_) => NearbyCafesProvider()),
        ChangeNotifierProvider(create: (_) => BookingCyberServiceProvider()),
        ChangeNotifierProvider(create: (_) => BookingDetailProvider()),
        ChangeNotifierProvider(create: (_) => UserNotificationProvider()),
        ChangeNotifierProvider(create: (_) => VendorNotificationProvider()),
        ChangeNotifierProvider(create: (_) => VendorBankProvider()),
        ChangeNotifierProvider(create: (_) => WorkingHoursProvider()),
        ChangeNotifierProvider(create: (_) => ProviderSlotBookingProvider()),
        ChangeNotifierProvider(create: (_) => MyBookingsUserProvider()),
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
        theme: ThemeData(textTheme: GoogleFonts.interTextTheme(),  useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),),
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/UserCustomBottomNav': (_) => const UserCustomBottomNav(),
          '/UserServiceDetailsScreen': (_) => const UserServiceDetailsScreen(),
          '/editProfile': (_) => const EditProfileScreen(),
          '/ProviderCustomBottomNav': (_) => const ProviderCustomBottomNav(),
          '/UserProfileScreen': (_) => const UserProfileScreen(),
          '/SubCatOfCatScreen': (_) => const SubCatOfCatScreen(),
          '/providerProfile': (_) => ProviderProfileScreen(),
          '/editProviderProfile': (_) => EditProviderProfileScreen(),
          '/ProviderOnboarding': (_) => const ProviderOnboardingDialog(),
          '/UserInstantServiceScreen': (_) =>
          const UserInstantServiceScreen(categoryId: 1, serviceType: ''),
        },
      ),
    );
  }
}
