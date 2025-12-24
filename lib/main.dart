import 'package:first_flutter/app_initializer.dart';
import 'package:first_flutter/my_app.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppInitializer.initialize();

  runApp(const MyApp());
}
