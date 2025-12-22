import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_flutter/screens/user_screens/Home/CategoryProvider.dart';
import 'package:first_flutter/screens/user_screens/SubCategory/SubCategoryProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CategoryCard extends StatelessWidget {
  final dynamic category;
  final CategoryProvider categoryProvider;

  const CategoryCard({required this.category, required this.categoryProvider});

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
