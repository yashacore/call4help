import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/nearby_cafe_provider.dart';
import 'package:first_flutter/screens/user_screens/cyber_cafe/time_slot_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NearbyCafesScreen extends StatefulWidget {
  const NearbyCafesScreen({super.key});

  @override
  State<NearbyCafesScreen> createState() => _NearbyCafesScreenState();
}

class _NearbyCafesScreenState extends State<NearbyCafesScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<NearbyCafesProvider>().fetchNearbyCafes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
          backgroundColor: ColorConstant.appColor,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text("Nearby Cyber Cafes")),
      body: Consumer<NearbyCafesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.cafes.isEmpty) {
            return const Center(child: Text("No cafes found nearby"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.cafes.length,
            itemBuilder: (context, index) {
              final cafe = provider.cafes[index];

              return  InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullDaySlotScreen(
                        cyberCafeId: cafe.id,
                        date: DateTime.now().toIso8601String().split('T').first,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// Shop Name
                      Text(
                        cafe.shopName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// Address
                      Text(
                        cafe.address,
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          /// Distance
                          Text(
                            "${cafe.distanceMeters} m away",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),

                          /// Available PCs
                          Chip(
                            backgroundColor: Colors.green.withOpacity(0.15),
                            label: Text(
                              "${cafe.availableComputers} PCs",
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
