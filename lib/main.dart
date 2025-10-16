import 'package:flutter/material.dart';
import 'screens/SplashScreen.dart';

void main() {
  runApp(const ReplateApp());
}

class ReplateApp extends StatelessWidget {
  const ReplateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
