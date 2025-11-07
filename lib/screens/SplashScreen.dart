import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'WelcomeScreen.dart';
import '../pages/HomePage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final supabase = Supabase.instance.client;
  @override
  void initState() {
    super.initState();
    _routeFromSplash();
  }

  Future<void> _routeFromSplash() async {
    // small splash pause
    await Future.delayed(const Duration(milliseconds: 1200));

    final session = supabase.auth.currentSession;

    if (!mounted) return;

    if (session != null) {
      // already signed in
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } else {
      // not signed in yet
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFE0B03A),
      body: Center(
        child: Text(
          'REPLATE',
          style: TextStyle(
            color: Color(0xFFE95322),
            fontSize: 36,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
