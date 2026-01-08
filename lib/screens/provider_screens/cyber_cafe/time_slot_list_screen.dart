import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/slot_list_provider.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/create_time_slot.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SlotsList extends StatefulWidget {
  const SlotsList({super.key});

  @override
  State<SlotsList> createState() => _SlotsListState();
}

class _SlotsListState extends State<SlotsList> {
  String _today() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SlotListProvider>().fetchSlots(_today());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ColorConstant.appColor,
          foregroundColor: Colors.white,
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateSlotTabsScreen(),
                ),
              );

              /// 🔄 REFRESH AFTER SLOT CREATION
              if (result == true) {
                context.read<SlotListProvider>().fetchSlots(_today());
              }


          },
        label: Text("Create Time Slot"),
      ),
      appBar: AppBar(
        centerTitle:true ,
          backgroundColor: ColorConstant.appColor,
          foregroundColor: Colors.white,
          title: const Text("Available Slots")),
      body: Consumer<SlotListProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.slots.length,
            itemBuilder: (context, index) {
              final slot = provider.slots[index];
              final isSelected = provider.selectedSlot?.id == slot.id;

              return _slotCard(context, provider, slot, isSelected);
            },
          );

        },
      ),
    );
  }Widget _slotCard(
      BuildContext context,
      SlotListProvider provider,
      dynamic slot,
      bool isSelected,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: slot.isLocked
            ? Colors.grey.shade200
            : isSelected
            ? Colors.green
            : Colors.white,
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// ⏰ TIME
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${slot.startTime} - ${slot.endTime}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${slot.availableSeats} seats available",
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          /// 🗑 DELETE
          InkWell(
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Delete Slot"),
                  content: const Text(
                    "Are you sure you want to delete this slot?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final ok = await provider.deleteSlot(slot.id);

                if (ok) {
                  provider.fetchSlots(_today()); // 🔄 refresh
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                      Text(provider.error ?? "Delete failed"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Icon(
              Icons.delete_outline,
              color: isSelected ? Colors.white : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

}
