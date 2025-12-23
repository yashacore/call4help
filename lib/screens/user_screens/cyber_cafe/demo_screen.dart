import 'package:first_flutter/screens/user_screens/cyber_cafe/my_bookings.dart';
import 'package:flutter/material.dart';

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyCyberBookings(),
              )
            );}, child: Text("My booking"))
        ],
      ),
    );
  }
}
