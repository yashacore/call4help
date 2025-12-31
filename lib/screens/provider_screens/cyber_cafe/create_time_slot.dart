import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/create_time_slot_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateSlotTabsScreen extends StatelessWidget {
  const CreateSlotTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Create Slots"),
          centerTitle: true,
          backgroundColor: ColorConstant.appColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            tabs: [
              Tab(text: "Manual"),
              Tab(text: "Auto Generate"),
            ],
          ),

        ),
        body: const TabBarView(
          children: [
            ManualCreateSlotTab(),
            AutoGenerateSlotScreen(

            ),
          ],
        ),
      ),
    );
  }
}


class ManualCreateSlotTab extends StatefulWidget {
  const ManualCreateSlotTab({super.key});

  @override
  State<ManualCreateSlotTab> createState() => _ManualCreateSlotTabState();
}

class _ManualCreateSlotTabState extends State<ManualCreateSlotTab> {
  final _formKey = GlobalKey<FormState>();
  final dateCtrl = TextEditingController();
  final startCtrl = TextEditingController();
  final endCtrl = TextEditingController();
  final seatCtrl = TextEditingController();

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      dateCtrl.text =
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> pickTime(TextEditingController ctrl) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      ctrl.text =
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }
  }

  @override
  void dispose() {
    dateCtrl.dispose();
    startCtrl.dispose();
    endCtrl.dispose();
    seatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(key: _formKey, child: _formCard()),
          ),
        ),
        _submitButton(),
      ],
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstant.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _dateField(),
          _timeField("Start Time", startCtrl),
          _timeField("End Time", endCtrl),
          _input("Total Seats", Icons.event_seat, seatCtrl,
              keyboard: TextInputType.number),
        ],
      ),
    );
  }

  Widget _input(String label, IconData icon, TextEditingController ctrl,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        validator: (v) => v == null || v.isEmpty ? "$label required" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ColorConstant.appColor),
          filled: true,
          fillColor: ColorConstant.scaffoldGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: dateCtrl,
        readOnly: true,
        validator: (v) => v == null || v.isEmpty ? "Date required" : null,
        onTap: pickDate,
        decoration: InputDecoration(
          labelText: "Date",
          prefixIcon:
          const Icon(Icons.calendar_today, color: ColorConstant.appColor),
          filled: true,
          fillColor: ColorConstant.scaffoldGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _timeField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        readOnly: true,
        validator: (v) => v == null || v.isEmpty ? "$label required" : null,
        onTap: () => pickTime(ctrl),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
          const Icon(Icons.access_time, color: ColorConstant.appColor),
          filled: true,
          fillColor: ColorConstant.scaffoldGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Consumer<CreateSlotProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstant.buttonBg,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
            ),
            onPressed: provider.isLoading
                ? null
                : () async {
              if (!_formKey.currentState!.validate()) return;

              if (endCtrl.text.compareTo(startCtrl.text) <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                    Text("End time must be after start time"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final res =
              await context.read<CreateSlotProvider>().createSlot(
                date: dateCtrl.text,
                startTime: startCtrl.text,
                endTime: endCtrl.text,
                totalSeats: seatCtrl.text,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(res.message),
                  backgroundColor:
                  res.success ? Colors.green : Colors.red,
                ),
              );
              if (res.success) {
                Navigator.pop(context, true); // 👈 RETURN SUCCESS
              }


              if (res.success) {
                dateCtrl.clear();
                startCtrl.clear();
                endCtrl.clear();
                seatCtrl.clear();
              }
            },
            child: provider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Create Slot"),
          ),
        );
      },
    );
  }
}




class AutoGenerateSlotScreen extends StatefulWidget {
  const AutoGenerateSlotScreen({super.key});

  @override
  State<AutoGenerateSlotScreen> createState() =>
      _AutoGenerateSlotScreenState();
}

class _AutoGenerateSlotScreenState extends State<AutoGenerateSlotScreen> {
  final _formKey = GlobalKey<FormState>();

  final dateCtrl = TextEditingController();
  final durationCtrl = TextEditingController(text: "30");
  final bufferCtrl = TextEditingController(text: "5");
  final seatsCtrl = TextEditingController(text: "20");

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      dateCtrl.text =
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _dateField(),
            _numberField("Slot Duration (minutes)", durationCtrl),
            _numberField("Buffer Time (minutes)", bufferCtrl),
            _numberField("Seats per Slot", seatsCtrl),
            const SizedBox(height: 20),

            Consumer<CreateSlotProvider>(
              builder: (context, provider, _) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstant.buttonBg,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                    if (!_formKey.currentState!.validate()) return;

                    final response =
                    await provider.autoGenerateSlots(
                      date: dateCtrl.text.trim(),
                      durationMinutes:
                      int.parse(durationCtrl.text),
                      bufferMinutes:
                      int.parse(bufferCtrl.text),
                      seatsPerSlot:
                      int.parse(seatsCtrl.text),
                    );
                    if (response.success) {
                      Navigator.pop(context, true); // 👈 RETURN SUCCESS
                    }


                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response.message),
                        backgroundColor: response.success
                            ? Colors.green
                            : Colors.red,
                      ),
                    );
                  },
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Auto Generate Slots"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField() {
    return TextFormField(
      controller: dateCtrl,
      readOnly: true,
      validator: (v) => v == null || v.isEmpty ? "Date required" : null,
      onTap: pickDate,
      decoration: const InputDecoration(
        labelText: "Date",
        prefixIcon: Icon(Icons.calendar_today),
      ),
    );
  }

  Widget _numberField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        validator: (v) => v == null || v.isEmpty ? "$label required" : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

