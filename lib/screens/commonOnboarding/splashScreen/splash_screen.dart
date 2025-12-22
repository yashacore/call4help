// splash_screen.dart
import 'package:first_flutter/providers/splash_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _videoController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();


    // Set a 3-second timer to navigate
    _timer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        final provider = Provider.of<SplashProvider>(context, listen: false);
        provider.initializeSplash((String route) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, route);
          }
        });
      }
    });
  }


  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle
          ),
          child: Image.asset(
            "assets/images/logo.png",
            width: 150,
            height: 150,
          ),
        ),
      ),
    );

  }
}
