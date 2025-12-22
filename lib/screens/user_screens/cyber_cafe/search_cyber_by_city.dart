import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/search_cyber_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchCyberCafeScreen extends StatefulWidget {
  const SearchCyberCafeScreen({super.key});

  @override
  State<SearchCyberCafeScreen> createState() => _SearchCyberCafeScreenState();
}

class _SearchCyberCafeScreenState extends State<SearchCyberCafeScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CyberCafeProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.appColor,
        title: const Text("Search Cyber Cafe"),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔍 Search Field
            TextFormField(
              controller: _cityController,
              onChanged: (value) {
                if (value.isEmpty) {
                  provider.reset(); // ⭐ reset state
                } else {
                  provider.loadStaticCafes(city: value);
                }
              },
              decoration: InputDecoration(
                hintText: "Enter city (e.g. Bhopal)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.location_city),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    provider.loadStaticCafes(
                      city: _cityController.text,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ⏳ Loading
            if (provider.isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )

            /// ❌ Error
            else if (provider.error != null)
              Expanded(
                child: Center(
                  child: Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )

            /// 🔍 DEFAULT STATE (NO SEARCH YET)
            else if (!provider.hasSearched)
                const Expanded(
                  child: Center(
                    child: Text(
                      "Search cyber cafe",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )

              /// 📭 EMPTY RESULT AFTER SEARCH
              else if (provider.cafes.isEmpty)
                  const Expanded(
                    child: Center(child: Text("No cyber cafes found")),
                  )

                /// 📋 RESULT LIST
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.cafes.length,
                      itemBuilder: (context, index) {
                        final cafe = provider.cafes[index];
                        return _CafeCard(cafe: cafe);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _CafeCard extends StatelessWidget {
  final Map<String, String> cafe;

  const _CafeCard({required this.cafe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 26, child: Icon(Icons.computer)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cafe['name'] ?? 'Cyber Cafe',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cafe['address'] ?? 'No address available',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
