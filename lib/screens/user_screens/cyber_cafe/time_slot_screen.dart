import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/time_slot_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SlotScreen extends StatefulWidget {
  const SlotScreen({super.key});

  @override
  State<SlotScreen> createState() => _SlotScreenState();
}

class _SlotScreenState extends State<SlotScreen> {
  final String cyberCafeId =
      "dd51bd94-5d1c-422c-9d0f-1312d440bb09";
  final String date = "2025-12-18";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SlotProvider>().fetchSlots(
        cyberCafeId: cyberCafeId,
        date: date,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.call4helpOrange,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorConstant.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Time Slot',
          style: TextStyle(
            color: ColorConstant.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<SlotProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _header(date, cyberCafeId),
              Expanded(
                child: GridView.builder(
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
                    final isSelected =
                        provider.selectedSlotId == slot.id;
                    final isDisabled =
                        slot.isLocked || slot.availableSeats == 0;

                    return GestureDetector(
                      onTap: isDisabled
                          ? null
                          : () => provider.selectSlot(slot.id),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: isDisabled
                              ? Colors.grey.shade300
                              : isSelected
                              ? Colors.orange.shade100
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? Colors.orange
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${slot.startTime} - ${slot.endTime}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isDisabled
                                  ? "Not Available"
                                  : "${slot.availableSeats} seats left",
                              style: TextStyle(
                                color: isDisabled
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar:
      Consumer<SlotProvider>(builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
               onPressed: provider.selectedSlotId == null || provider.isLoading
          ? null
              : () async {
        await provider.bookSlot();
        provider.showSuccessSnackBar(
            "Slot booked successfully", context);
        },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstant.call4helpOrange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 2,
            ),
            child: Text(
              'Instant',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }),
    );
  }Widget _header(String date, String cafeId) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Date: $date",
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            cafeId,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

}
