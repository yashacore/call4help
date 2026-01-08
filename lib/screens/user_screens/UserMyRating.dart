import 'package:first_flutter/config/baseControllers/APis.dart';
import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class UserMyRating extends StatefulWidget {
  const UserMyRating({Key? key}) : super(key: key);

  @override
  State<UserMyRating> createState() => _UserMyRatingState();
}

class _UserMyRatingState extends State<UserMyRating> {
  bool isLoading = true;
  Map<String, dynamic>? ratingData;
  List<dynamic> individualRatings = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await Future.wait([fetchAverageRatings(), fetchIndividualRatings()]);
  }

  Future<void> fetchAverageRatings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$base_url/bid/api/user/average'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ratingData = data;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load average ratings';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> fetchIndividualRatings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final providerId = prefs.getInt('user_id');

      if (providerId == null) {
        setState(() {
          errorMessage = 'Provider ID not found';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$base_url/bid/api/user/user/$providerId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if (data['success'] == true && data['data'] != null) {
            individualRatings = data['data'];
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load individual ratings';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Map<int, int> _calculateRatingDistribution() {
    Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var rating in individualRatings) {
      int stars = rating['rating'] ?? 0;
      if (stars >= 1 && stars <= 5) {
        distribution[stars] = (distribution[stars] ?? 0) + 1;
      }
    }
    return distribution;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.scaffoldGray,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorConstant.call4helpOrangeFade.withValues(alpha:0.3),
              ColorConstant.scaffoldGray,
            ],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: ColorConstant.call4helpOrange,
                  ),
                )
              : errorMessage != null
              ? _buildErrorWidget()
              : _buildRatingContent(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    debugPrint(errorMessage);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              errorMessage!,
              style: TextStyle(fontSize: 16.sp, color: ColorConstant.onSurface),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                fetchData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstant.call4helpOrange,
                foregroundColor: ColorConstant.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text('Retry', style: TextStyle(fontSize: 16.sp)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingContent() {
    final averageRating = ratingData?['average_rating']?.toDouble() ?? 0.0;
    final totalRatings =
        ratingData?['total_ratings'] ?? individualRatings.length;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: ColorConstant.onSurface,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'My Ratings',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorConstant.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),

            // Main Rating Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorConstant.call4helpOrange,
                    ColorConstant.call4helpScaffoldGradient,
                  ],
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: ColorConstant.call4helpOrange.withValues(alpha:0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Average Rating',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.white.withValues(alpha:0.9),
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 72.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorConstant.white,
                      height: 1,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildStarRating(averageRating),
                  SizedBox(height: 16.h),
                  Text(
                    'Based on $totalRatings ${totalRatings == 1 ? 'review' : 'reviews'}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: ColorConstant.white.withValues(alpha:0.85),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.star_rounded,
                    title: 'Total Reviews',
                    value: totalRatings.toString(),
                    color: ColorConstant.darkPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Rating Breakdown
            _buildRatingBreakdown(),
            SizedBox(height: 24.h),

            // Individual Reviews
            if (individualRatings.isNotEmpty) ...[
              Text(
                'Recent Reviews',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorConstant.onSurface,
                ),
              ),
              SizedBox(height: 16.h),
              ...individualRatings
                  .map((rating) => _buildReviewCard(rating))
                  .toList(),
            ] else ...[
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: ColorConstant.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 48.sp,
                        color: ColorConstant.onSurface.withValues(alpha:0.3),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'No reviews yet',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: ColorConstant.onSurface.withValues(alpha:0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(dynamic rating) {
    final stars = rating['rating'] ?? 0;
    final review = rating['review'] ?? 'No review text';
    final createdAt = rating['created_at'] ?? '';

    DateTime? date;
    try {
      date = DateTime.parse(createdAt);
    } catch (e) {
      date = null;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: ColorConstant.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < stars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: index < stars
                        ? ColorConstant.call4helpOrange
                        : ColorConstant.onSurface.withValues(alpha:0.3),
                    size: 20.sp,
                  );
                }),
              ),
              if (date != null)
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: ColorConstant.onSurface.withValues(alpha:0.5),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            review,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorConstant.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(
            Icons.star_rounded,
            color: ColorConstant.white,
            size: 32.sp,
          );
        } else if (index < rating) {
          return Icon(
            Icons.star_half_rounded,
            color: ColorConstant.white,
            size: 32.sp,
          );
        } else {
          return Icon(
            Icons.star_outline_rounded,
            color: ColorConstant.white.withValues(alpha:0.5),
            size: 32.sp,
          );
        }
      }),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: ColorConstant.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha:0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: ColorConstant.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: ColorConstant.onSurface.withValues(alpha:0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown() {
    final distribution = _calculateRatingDistribution();
    final total = individualRatings.length;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: ColorConstant.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rating Details',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: ColorConstant.onSurface,
            ),
          ),
          SizedBox(height: 20.h),
          _buildRatingBar(
            5,
            total > 0 ? (distribution[5] ?? 0) / total : 0.0,
            distribution[5] ?? 0,
          ),
          SizedBox(height: 12.h),
          _buildRatingBar(
            4,
            total > 0 ? (distribution[4] ?? 0) / total : 0.0,
            distribution[4] ?? 0,
          ),
          SizedBox(height: 12.h),
          _buildRatingBar(
            3,
            total > 0 ? (distribution[3] ?? 0) / total : 0.0,
            distribution[3] ?? 0,
          ),
          SizedBox(height: 12.h),
          _buildRatingBar(
            2,
            total > 0 ? (distribution[2] ?? 0) / total : 0.0,
            distribution[2] ?? 0,
          ),
          SizedBox(height: 12.h),
          _buildRatingBar(
            1,
            total > 0 ? (distribution[1] ?? 0) / total : 0.0,
            distribution[1] ?? 0,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage, int count) {
    return Row(
      children: [
        Text(
          '$stars',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: ColorConstant.onSurface,
          ),
        ),
        SizedBox(width: 4.w),
        Icon(Icons.star, size: 16.sp, color: ColorConstant.call4helpOrange),
        SizedBox(width: 12.w),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: ColorConstant.call4helpOrangeFade.withValues(alpha:0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                ColorConstant.call4helpOrange,
              ),
              minHeight: 8.h,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          '${(percentage * 100).toInt()}% ($count)',
          style: TextStyle(
            fontSize: 12.sp,
            color: ColorConstant.onSurface.withValues(alpha:0.6),
          ),
        ),
      ],
    );
  }
}
