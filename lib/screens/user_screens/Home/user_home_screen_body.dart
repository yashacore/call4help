import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_flutter/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/screens/user_screens/Home/top_services.dart';
import 'package:first_flutter/screens/user_screens/cyber_cafe/search_cyber_by_city.dart';
import 'package:first_flutter/screens/user_screens/razor_pay/razor_pay_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../BannerModel.dart';
import '../../../widgets/image_slider.dart';
import '../SubCategory/SubCategoryProvider.dart';
import 'CategoryProvider.dart';

class UserHomeScreenBody extends StatefulWidget {
  const UserHomeScreenBody({super.key});

  @override
  State<UserHomeScreenBody> createState() => _UserHomeScreenBodyState();
}

class _UserHomeScreenBodyState extends State<UserHomeScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
      context.read<CarouselProvider>().fetchCarousels(type: 'user');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SingleChildScrollView(
        child: Column(
          spacing: 10,
          children: [
            Consumer<CarouselProvider>(
              builder: (context, carouselProvider, child) {
                if (carouselProvider.isLoading) {
                  return Container(
                    height: 160,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (carouselProvider.errorMessage != null) {
                  return Container(
                    height: 160,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(height: 8),
                          const Text(
                            'Failed to load carousel',
                            style: TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              carouselProvider.fetchCarousels(type: 'user');
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (carouselProvider.carousels.isEmpty) {
                  return Container(
                    height: 160,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'No carousel items available',
                        style: GoogleFonts.inter(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }

                final imageLinks = carouselProvider.carousels
                    .map((carousel) => carousel.imageUrl)
                    .toList();

                return ImageSlider(imageLinks: imageLinks);
              },
            ),

            // ElevatedButton(
            //   onPressed: () {
            //     final amount = 100;
            //
            //
            //
            //     final razorpay = RazorpayService();
            //
            //     razorpay.init(
            //       onSuccess: (PaymentSuccessResponse res) {
            //         debugPrint("✅ PAYMENT SUCCESS");
            //         debugPrint("paymentId  : ${res.paymentId}");
            //         debugPrint("orderId    : ${res.orderId}");
            //         debugPrint("signature  : ${res.signature}");
            //         debugPrint("raw object : ${res.toString()}");
            //
            //       },
            //       onError: (PaymentFailureResponse res) {
            //         debugPrint("❌ PAYMENT FAILED");
            //         debugPrint("code       : ${res.code}");
            //         debugPrint("message    : ${res.message}");
            //         debugPrint("error      : ${res.error}");
            //         debugPrint("raw object : ${res.toString()}");
            //
            //
            //       },
            //       onWallet: (ExternalWalletResponse res) {
            //         debugPrint("🟡 EXTERNAL WALLET SELECTED");
            //         debugPrint("walletName : ${res.walletName}");
            //         debugPrint("raw object : ${res.toString()}");
            //       },
            //     );
            //
            //     razorpay.openCheckout(
            //       amount: amount, // ₹ value (your service should convert to paise)
            //       key: "rzp_test_RrrFFdWCi6TIZG",
            //       name: "Call4Help",
            //       description: "Service Payment",
            //       contact: "9999999999",
            //       email: "test@email.com",
            //     );
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: ColorConstant.call4hepGreen,
            //   ),
            //   child: const Text("Pay Amount"),
            // ),
            const HomeTopServices(),
            SizedBox(
              width: double.infinity,
              child: Text(
                "Service Offering",
                textAlign: TextAlign.start,
                style: GoogleFonts.inter(
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                if (categoryProvider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (categoryProvider.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            categoryProvider.errorMessage ??
                                'An error occurred',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              categoryProvider.fetchCategories();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (categoryProvider.categories.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No categories available',
                        style: GoogleFonts.inter(
                          textStyle: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 16,
                    runSpacing: 16,
                    children: categoryProvider.categories.map((category) {
                      return _CategoryCard(
                        category: category,
                        categoryProvider: categoryProvider,
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            ElevatedButton(onPressed: (){
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => SearchCyberCafeScreen()));
            }, child: Text("Cyber Cafe"))
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final dynamic category;
  final CategoryProvider categoryProvider;

  const _CategoryCard({required this.category, required this.categoryProvider});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32 - 48) / 4;

    final imageUrl = category.icon != null && category.icon.isNotEmpty
        ? category.icon
        : null;

    return InkWell(
      onTap: () {
        context.read<SubCategoryProvider>().clearSubcategories();
        Navigator.pushNamed(context, '/SubCatOfCatScreen', arguments: category);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        width: cardWidth,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
              ),
              height: 48,
              width: 48,
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Image.asset(
                        'assets/images/moyo_service_placeholder.png',
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/moyo_service_placeholder.png',
                      ),
                    )
                  : Image.asset('assets/images/moyo_service_placeholder.png'),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.name ?? "Category",
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF000000),
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
