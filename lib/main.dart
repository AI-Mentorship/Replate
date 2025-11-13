import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/SplashScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tbegucrdazfhzrcfwahe.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRiZWd1Y3JkYXpmaHpyY2Z3YWhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEzNDI2MTYsImV4cCI6MjA3NjkxODYxNn0.GCAq3sNBzmOW66r9VzBPKzorq_v2ycdd4SWQhSbVTm0',
  );

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
