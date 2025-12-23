import 'package:first_flutter/providers/slot_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SlotsList extends StatefulWidget {
  const SlotsList({super.key});

  @override
  State<SlotsList> createState() => _SlotsListState();
}

class _SlotsListState extends State<SlotsList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SlotListProvider>().fetchSlots("2025-12-23");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Slots")),
      body: Consumer<SlotListProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.4,
            ),
            itemCount: provider.slots.length,
            itemBuilder: (context, index) {
              final slot = provider.slots[index];
              final isSelected = provider.selectedSlot?.id == slot.id;

              return GestureDetector(
                onTap: slot.isLocked
                    ? null
                    : () => provider.selectSlot(slot),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? Colors.green
                        : slot.isLocked
                        ? Colors.grey.shade300
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? Colors.green
                          : Colors.grey.shade300,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${slot.startTime} - ${slot.endTime}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                          isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${slot.availableSeats} seats available",
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white70
                              : Colors.grey,
                        ),
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
