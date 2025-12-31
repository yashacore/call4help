import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/screens/user_screens/cyber_cafe/nearby_cafe_screen.dart';
import 'package:first_flutter/screens/user_screens/cyber_cafe/time_slot_screen.dart';
import 'package:first_flutter/widgets/user_only_title_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/UpdateProfileDialog.dart';
import '../../../data/models/CatehoryModel.dart';
import '../User Instant Service/user_instant_service_screen.dart';
import 'SubCategoryProvider.dart';

class SubCatOfCatScreen extends StatefulWidget {
  const SubCatOfCatScreen({super.key});

  @override
  State<SubCatOfCatScreen> createState() => _SubCatOfCatScreenState();
}

class _SubCatOfCatScreenState extends State<SubCatOfCatScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Category) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SubCategoryProvider>().fetchSubcategories(arguments.id);
      });
    } else if (arguments is Map<String, dynamic>) {
      final categoryId = arguments['id'] ?? arguments['categoryId'];
      if (categoryId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<SubCategoryProvider>().fetchSubcategories(categoryId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final categoryName = arguments is Category
        ? arguments.name
        : 'Sub Categories';

    return Scaffold(
      appBar: UserOnlyTitleAppbar(title: categoryName),
      body: _subCategory(context),
    );
  }

  Widget _subCategory(BuildContext context) {
    return Consumer<SubCategoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: ColorConstant.call4helpOrange),
          );
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 64.sp),
                  SizedBox(height: 16.h),
                  Text(
                    provider.errorMessage ?? 'An error occurred',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      final arguments = ModalRoute.of(
                        context,
                      )?.settings.arguments;
                      if (arguments is Category) {
                        provider.fetchSubcategories(arguments.id);
                      } else if (arguments is Map<String, dynamic>) {
                        final categoryId =
                            arguments['id'] ?? arguments['categoryId'];
                        if (categoryId != null) {
                          provider.fetchSubcategories(categoryId);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstant.call4helpOrange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.subcategories.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    'No subcategories available',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(8.w),
          itemCount: provider.subcategories.length,
          itemBuilder: (context, index) {
            final subcategory = provider.subcategories[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 6.h),
              child: UserExpansionTileListCard(subcategory: subcategory),
            );
          },
        );
      },
    );
  }
}

class UserExpansionTileListCard extends StatelessWidget {
  final SubCategory subcategory;

  const UserExpansionTileListCard({super.key, required this.subcategory});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            leading: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.r),
              ),
              height: 45.w,
              width: 45.w,
              child: CachedNetworkImage(
                imageUrl: subcategory.icon,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Image.asset('assets/images/moyo_image_placeholder.png'),
                errorWidget: (context, url, error) =>
                    Image.asset('assets/images/moyo_image_placeholder.png'),
              ),
            ),
            title: Text(
              subcategory.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '₹${subcategory.hourlyRate}/hr',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
            childrenPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),
                          Text(
                            'Choose Service Type',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color: ColorConstant.black,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _buildServiceButtons(context),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildServiceButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _handleServiceTypeSelection(context, 'instant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstant.call4helpOrange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 2,
            ),
            child: Text(
              'Instant',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _handleServiceTypeSelection(context, 'later'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: ColorConstant.call4helpOrange, width: 2),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Later',
              style: TextStyle(
                color: ColorConstant.call4helpOrange,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
  void _handleServiceTypeSelection(
      BuildContext context,
      String serviceType,
      ) async {
    debugPrint('==============================');
    debugPrint('➡️ Service type selected: $serviceType');

    final prefs = await SharedPreferences.getInstance();
    final isEmailVerified = prefs.getBool('is_email_verified') ?? false;
    final userMobile = prefs.getString('user_mobile') ?? '';

    debugPrint('📧 Email verified: $isEmailVerified');
    debugPrint('📱 User mobile: $userMobile');

    if (!isEmailVerified || userMobile.isEmpty) {
      debugPrint('⚠️ Profile incomplete, showing UpdateProfileDialog');

      await UpdateProfileDialog.show(context);

      final updatedPrefs = await SharedPreferences.getInstance();
      final updatedEmailVerified =
          updatedPrefs.getBool('is_email_verified') ?? false;
      final updatedMobile = updatedPrefs.getString('user_mobile') ?? '';

      debugPrint('🔁 After dialog → Email verified: $updatedEmailVerified');
      debugPrint('🔁 After dialog → Mobile: $updatedMobile');

      if (!updatedEmailVerified || updatedMobile.isEmpty) {
        debugPrint('❌ Profile still incomplete. Navigation stopped.');
        return;
      }
    }

    debugPrint('✅ Profile verified. Proceeding with navigation.');

    // 🔎 GET CATEGORY FROM ROUTE
    final args = ModalRoute.of(context)?.settings.arguments;
    debugPrint('📦 Route arguments: $args');

    int categoryId = 0;
    String categoryName = '';

    if (args is Category) {
      categoryId = args.id;
      categoryName = args.name;
      debugPrint('🟢 Category from args (Category object)');
    } else if (args is Map<String, dynamic>) {
      categoryId = args['id'] ?? args['categoryId'] ?? 0;
      categoryName = args['name'] ?? '';
      debugPrint('🟢 Category from args (Map)');
    } else {
      debugPrint('🔴 No category found in route arguments');
    }

    debugPrint('🆔 Category ID: $categoryId');
    debugPrint('🏷️ Category Name (raw): $categoryName');

    final normalizedCategoryName =
    categoryName.toLowerCase().trim();

    debugPrint('🏷️ Category Name (normalized): $normalizedCategoryName');

    // 🧠 FINAL CONDITION
    if (categoryId == 4 || normalizedCategoryName.contains('cyber')) {
      debugPrint('🚀 CONDITION MATCHED → Navigating to SlotScreen');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const NearbyCafesScreen(),
        ),
      );
    } else {
      debugPrint('➡️ CONDITION NOT MATCHED → Navigating to UserInstantServiceScreen');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserInstantServiceScreen(
            categoryId: categoryId,
            categoryName: categoryName.isNotEmpty
                ? categoryName
                : subcategory.name,
            serviceType: serviceType,
          ),
        ),
      );
    }

    debugPrint('==============================');
  }

}

