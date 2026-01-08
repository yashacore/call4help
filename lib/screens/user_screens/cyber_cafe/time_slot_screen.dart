import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/time_slot_provider.dart';
import 'package:first_flutter/screens/user_screens/cyber_cafe/book_cafe_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FullDaySlotScreen extends StatelessWidget {
  final String cyberCafeId;
  final String date;
  final String hourlyRate;
  final String subcategoryId;

  const FullDaySlotScreen({
    super.key,
    required this.cyberCafeId,
    required this.date,
    required this.hourlyRate,
    required this.subcategoryId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          SlotProvider()
            ..fetchFullDaySlots(cyberCafeId: cyberCafeId, date: date),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorConstant.call4helpOrange,
          foregroundColor: Colors.white,
          title: const Text("All Time Slots"),
          centerTitle: true,
        ),
        body: Consumer<SlotProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.slots.isEmpty) {
              return const Center(child: Text("No slots available"));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.slots.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (context, index) {
                final slot = provider.slots[index];
                final isSelected = provider.selectedSlotId == slot.apiSlot.id;

                Color bg;
                Color border;
                String label;

                switch (slot.status) {
                  case SlotUIStatus.available:
                    bg = isSelected ? Colors.green.shade50 : Colors.white;
                    border = isSelected ? Colors.green : Colors.green;
                    label = "${slot.apiSlot.availableSeats} seats";
                    break;

                  case SlotUIStatus.full:
                    bg = Colors.orange.shade100;
                    border = Colors.orange;
                    label = "Full";
                    break;

                  case SlotUIStatus.locked:
                    bg = Colors.grey.shade300;
                    border = Colors.grey;
                    label = "Locked";
                    break;
                }

                final disabled = slot.status != SlotUIStatus.available;

                return InkWell(
                  onTap: disabled
                      ? null
                      : () {
                    // ✅ SELECT SLOT
                    provider.selectSlot(slot.apiSlot.id);

                    // ✅ NAVIGATE
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookSlotScreen(
                          slotId: slot.apiSlot.id,
                          hourlyRate: hourlyRate,
                          subcategoryId: subcategoryId,
                          duration:
                          "${slot.startTime.substring(0, 5)} - ${slot.endTime.substring(0, 5)}",
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: border,
                        width: isSelected ? 2.5 : 1.2, // ⭐ highlight
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${slot.startTime.substring(0, 5)} - ${slot.endTime.substring(0, 5)}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.green : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: TextStyle(
                            color: border,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 6),
                          const Icon(Icons.check_circle, color: Colors.green, size: 18),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
