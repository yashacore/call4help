import 'package:first_flutter/screens/provider_screens/bank_section/add_bank_account_screen.dart';
import 'package:first_flutter/screens/provider_screens/bank_section/vendor_bank_details_screen.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/booking_list.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/create_time_slot.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/nearby_cafe_screen.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/register_cafe.dart';
import 'package:first_flutter/screens/provider_screens/cyber_cafe/time_slot_list_screen.dart';
import 'package:flutter/material.dart';

class TesingScreen extends StatelessWidget {
  const TesingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CyberCafeRegisterScreen(),
                ),
              );
            },
            child: Text("Register Cafe"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateSlotScreen()),
              );
            },
            child: Text("Create Time"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SlotsList()),
              );
            },
            child: Text("Slot list"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProviderSlotsDashboard(),
                ),
              );
            },
            child: Text("Booking Dashboard"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NearbyCafesScreen()),
              );
            },
            child: Text("Near by cafe"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProviderBankScreen()),
              );
            },
            child: Text("create bank account"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProviderBankDetailsScreen(),
                ),
              );
            },
            child: Text("my bank account"),
          ),
        ],
      ),
    );
  }
}
