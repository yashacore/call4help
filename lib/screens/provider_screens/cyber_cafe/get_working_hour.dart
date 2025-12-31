import 'package:first_flutter/providers/working_hour_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkingHoursViewScreen extends StatefulWidget {
  const WorkingHoursViewScreen({super.key});

  @override
  State<WorkingHoursViewScreen> createState() => _WorkingHoursViewScreenState();
}

class _WorkingHoursViewScreenState extends State<WorkingHoursViewScreen> {
  final days = const [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<WorkingHoursProvider>().fetchWorkingHours(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Working Hours")),
      body: Consumer<WorkingHoursProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.hours.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hours.isEmpty) {
            return const Center(child: Text("No working hours found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.hours.length,
            itemBuilder: (_, i) {
              final h = provider.hours[i];

              return Card(
                child: ListTile(
                  title: Text(days[h.dayOfWeek]),
                  subtitle: h.isClosed
                      ? const Text("Closed")
                      : Text("${_fmt(h.openTime)} - ${_fmt(h.closeTime)}"),

                  /// 🔘 OPEN / CLOSE
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: !h.isClosed,
                        onChanged: (v) async {
                          bool ok = v
                              ? await provider.openDay(h.dayOfWeek)
                              : await provider.closeDay(h.dayOfWeek);
                          if (ok) provider.fetchWorkingHours();
                        },
                      ),

                      /// 🗑 DELETE
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final ok = await provider.deleteDay(h.dayOfWeek);
                          if (ok) provider.fetchWorkingHours();
                        },
                      ),
                    ],
                  ),

                  /// ✏️ EDIT TIME
                  onTap: () async {
                    final open = await _pick(context, h.openTime);
                    final close = await _pick(context, h.closeTime);

                    if (open != null && close != null) {
                      final ok = await provider.updateDay(
                        day: h.dayOfWeek,
                        openTime: open,
                        closeTime: close,
                        isClosed: h.isClosed,
                      );
                      if (ok) provider.fetchWorkingHours();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String?> _pick(BuildContext context, String time) async {
    final parts = time.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
    );
    if (picked == null) return null;
    return "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
  }

  String _fmt(String t) => t.substring(0, 5);
}
