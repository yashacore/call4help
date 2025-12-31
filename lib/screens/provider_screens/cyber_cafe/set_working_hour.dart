import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/working_hour_provider.dart';
import 'package:first_flutter/widgets/button_large.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetWorkingHoursScreen extends StatefulWidget {
  const SetWorkingHoursScreen({super.key});

  @override
  State<SetWorkingHoursScreen> createState() => _SetWorkingHoursScreenState();
}

class _SetWorkingHoursScreenState extends State<SetWorkingHoursScreen> {
  final List<String> days = const [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  late List<TimeOfDay> openTimes;
  late List<TimeOfDay> closeTimes;
  late List<bool> isClosed;

  @override
  void initState() {
    super.initState();
    openTimes =
        List.generate(7, (_) => const TimeOfDay(hour: 9, minute: 0));
    closeTimes =
        List.generate(7, (_) => const TimeOfDay(hour: 18, minute: 0));
    isClosed = List.generate(7, (_) => false);
  }

  Future<void> pickTime(int index, bool isOpen) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpen ? openTimes[index] : closeTimes[index],
    );
    if (picked != null) {
      setState(() {
        if (isOpen) {
          openTimes[index] = picked;
        } else {
          closeTimes[index] = picked;
        }
      });
    }
  }

  String _format(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor : ColorConstant.appColor,
        foregroundColor: Colors.white,
        title: const Text("Working Hours"),
        centerTitle: true,
      ),
      body: Consumer<WorkingHoursProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    return _dayCard(index);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ButtonLarge(
                  onTap: provider.isLoading
                      ? null
                      : () async {
                    final payload = List.generate(7, (i) {
                      return {
                        "day_of_week": i,
                        "open_time": _format(openTimes[i]),
                        "close_time": _format(closeTimes[i]),
                        "is_closed": isClosed[i],
                      };
                    });

                    final success = await provider.setWorkingHours(
                      payload,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? "✅ Working hours saved"
                            : "❌ Failed to save"),
                        backgroundColor:
                        success ? Colors.green : Colors.red,
                      ),
                    );
                  },

                  label: "Save Working Hours"
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dayCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  days[index],
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Switch(
                  value: !isClosed[index],
                  onChanged: (v) {
                    setState(() {
                      isClosed[index] = !v;
                    });
                  },
                ),
                Text(isClosed[index] ? "Closed" : "Open"),
              ],
            ),
            if (!isClosed[index]) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _timeBox(
                    "Open",
                    _format(openTimes[index]),
                        () => pickTime(index, true),
                  ),
                  const SizedBox(width: 12),
                  _timeBox(
                    "Close",
                    _format(closeTimes[index]),
                        () => pickTime(index, false),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timeBox(String label, String time, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Column(
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                time,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
