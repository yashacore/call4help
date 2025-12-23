import 'package:first_flutter/config/constants/colorConstant/color_constant.dart';
import 'package:first_flutter/providers/create_time_slot_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateSlotScreen extends StatefulWidget {
  const CreateSlotScreen({super.key});

  @override
  State<CreateSlotScreen> createState() => _CreateSlotScreenState();
}

class _CreateSlotScreenState extends State<CreateSlotScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Slot"),
        centerTitle: true,
        backgroundColor: ColorConstant.appColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: ColorConstant.scaffoldGray,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: _formCard(),
              ),
            ),
          ),
          _submitButton(),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstant.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
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

  Widget _input(
      String label,
      IconData icon,
      TextEditingController ctrl, {
        TextInputType keyboard = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        validator: (v) =>
        v == null || v.isEmpty ? "$label required" : null,
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
        validator: (v) =>
        v == null || v.isEmpty ? "Date required" : null,
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
        validator: (v) =>
        v == null || v.isEmpty ? "$label required" : null,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: provider.isLoading
                ? null
                : () async {
              if (!_formKey.currentState!.validate()) return;

              final success = await provider.createSlot(
                date: dateCtrl.text,
                startTime: startCtrl.text,
                endTime: endCtrl.text,
                totalSeats: seatCtrl.text,
              );
              ScaffoldMessenger.of(context).showSnackBar(

                SnackBar(
                  content: Text(
                       "✅ Slot created successfully"
                     ),
                ),
              );


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
