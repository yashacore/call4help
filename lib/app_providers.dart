import 'package:first_flutter/providers/splash_screen_provider.dart';
import 'package:provider/provider.dart';
import 'package:first_flutter/data/api_services/provider_confirmed_service.dart';
import 'package:first_flutter/providers/availability_provider.dart';
import 'package:first_flutter/providers/EarningsProvider.dart';
import 'package:first_flutter/providers/EditProviderProfileProvider.dart';
import 'package:first_flutter/providers/MySkillProvider.dart';
import 'package:first_flutter/providers/ProviderBidProvider.dart';
import 'package:first_flutter/providers/ProviderProfileProvider.dart';
import 'package:first_flutter/providers/ServiceArrivalProvider.dart';
import 'package:first_flutter/providers/SettingsProvider.dart';
import 'package:first_flutter/providers/SubcategoryProvider.dart';
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
import 'package:first_flutter/screens/provider_screens/LegalDocumentScreen.dart';
import 'package:first_flutter/providers/StartWorkProvider.dart';
import 'package:first_flutter/screens/provider_screens/navigation/NotificationProvider.dart';
import 'package:first_flutter/screens/provider_screens/navigation/ProviderChats/ProviderChatProvider.dart';
import 'package:first_flutter/screens/provider_screens/navigation/UserNotificationProvider.dart';
import 'package:first_flutter/providers/MyAddressProvider.dart';
import 'package:first_flutter/providers/book_provider_provider.dart';
import 'package:first_flutter/providers/CategoryProvider.dart';
import 'package:first_flutter/providers/EditProfileProvider.dart';
import 'package:first_flutter/screens/sub_category/SkillProvider.dart';
import 'package:first_flutter/screens/user_screens/Profile/FAQProvider.dart';
import 'package:first_flutter/providers/UserProfileProvider.dart';
import 'package:first_flutter/screens/user_screens/SubCategory/SubCategoryProvider.dart';
import 'package:first_flutter/providers/SubCategoryStateProvider.dart';
import 'package:first_flutter/providers/UserInstantServiceProvider.dart';
import 'package:first_flutter/screens/user_screens/navigation/EmergencyContactProvider.dart';
import 'package:first_flutter/screens/user_screens/navigation/SOSProvider.dart';
import 'package:first_flutter/screens/user_screens/navigation/UserChats/UserChatProvider.dart';
import 'package:first_flutter/screens/user_screens/navigation/UserSOSProvider.dart';
import 'package:first_flutter/screens/user_screens/navigation/user_service_tab_body/ServiceProvider.dart';
import 'package:first_flutter/screens/user_screens/navigation/user_service_tab_body/UserCompletedServiceProvider.dart';
import 'data/models/BannerModel.dart';
import 'providers/booking_cyber_user_provider.dart';

List<ChangeNotifierProvider> appProviders = [
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
  ChangeNotifierProvider(create: (_) => ProviderSlotsStatusProvider()),
  ChangeNotifierProvider(create: (_) => NearbyCafesProvider()),
  ChangeNotifierProvider(create: (_) => BookingCyberServiceProvider()),
  ChangeNotifierProvider(create: (_) => BookingDetailProvider()),
  ChangeNotifierProvider(create: (_) => UserNotificationProvider()),
  ChangeNotifierProvider(create: (_) => VendorNotificationProvider()),
  ChangeNotifierProvider(create: (_) => VendorBankProvider()),
];
