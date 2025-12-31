import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/time_slot_provider.dart';
import 'package:first_flutter/screens/user_screens/cyber_cafe/book_cafe_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FullDaySlotScreen extends StatelessWidget {
  final String cyberCafeId;
  final String date;

  const FullDaySlotScreen({
    super.key,
    required this.cyberCafeId,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SlotProvider()
        ..fetchFullDaySlots(
          cyberCafeId: cyberCafeId,
          date: date,
        ),
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
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (context, index) {
                final slot = provider.slots[index];

                Color bg;
                Color border;
                String label;

                switch (slot.status) {
                  case SlotUIStatus.available:
                    bg = Colors.white;
                    border = Colors.green;
                    label =
                    "${slot.apiSlot!.availableSeats} seats";
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
                  case SlotUIStatus.notCreated:
                    bg = Colors.red.shade50;
                    border = Colors.red;
                    label = "Not Created";
                    break;
                }

                final disabled =
                    slot.status != SlotUIStatus.available;

                return InkWell(
                  onTap: disabled
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookSlotScreen(
                        slotId: slot.apiSlot!.id,

                      ),
                    ),
                  );
                },

                child: Container(
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${slot.startTime.substring(0, 5)} - ${slot.endTime.substring(0, 5)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: TextStyle(color: border),
                        ),
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
