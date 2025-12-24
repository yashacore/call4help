import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeTopServices extends StatefulWidget {
  const HomeTopServices({super.key});

  @override
  State<HomeTopServices> createState() => _HomeTopServicesState();
}

class _HomeTopServicesState extends State<HomeTopServices>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Animation<double>> _fadeAnimations = [];
  List<Animation<Offset>> _slideAnimations = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  void generateAnimations(int total) {
    _fadeAnimations = List.generate(total, (i) {
      final start = (i * 0.15).clamp(0.0, 1.0);
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnimations = List.generate(total, (i) {
      final start = (i * 0.15).clamp(0.0, 1.0);
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> destinations = [
      {
        "image": "assets/images/car-service.jpg",
        "name": "Car Repair",
        "reviews": "Review 150",
        "rating": "5.0",
      },
      {
        "image": "assets/images/home-tutor.jpg",
        "name": "Home Tutor",
        "reviews": "Review 49",
        "rating": "4.0",
      },
      {
        "image": "assets/images/home_clean.jpg",
        "name": "Home Cleaning",
        "reviews": "Review 25",
        "rating": "3.0",
      },
    ];

    if (_fadeAnimations.length != destinations.length) {
      generateAnimations(destinations.length);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Top Services",
                textAlign: TextAlign.start,
                style: GoogleFonts.inter(
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Color(0xFF000000),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text("see all", style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 15),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(destinations.length, (index) {
                final item = destinations[index];

                return FadeTransition(
                  opacity: _fadeAnimations[index],
                  child: SlideTransition(
                    position: _slideAnimations[index],
                    child: Container(
                      // color: Colors.grey.shade300,
                      width: 150,
                      margin: const EdgeInsets.only(right: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Material(
                          color: Colors.grey.shade300,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                item["image"]!,
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["name"]!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item["reviews"]!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          item["rating"]!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
