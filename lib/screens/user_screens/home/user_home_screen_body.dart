import 'package:first_flutter/providers/category_provider.dart';
import 'package:first_flutter/screens/user_screens/Home/category_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../data/models/BannerModel.dart';
import '../../../widgets/image_slider.dart';

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
                      return CategoryCard(
                        category: category,
                        categoryProvider: categoryProvider,
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => NotificationTestScreen()),
            //     );
            //   },
            //   child: Text("Cyber Cafe"),
            // ),
          ],
        ),
      ),
    );
  }
}
