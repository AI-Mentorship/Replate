import 'package:flutter/material.dart';

class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
  bool darkMode = false;
  bool notifications = true;
  String units = 'Metric';
  String assistantMode = 'Voice-Guided';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFE95322)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'App Preferences',
          style: TextStyle(
            color: Color(0xFF391713),
            fontFamily: 'League Spartan',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: darkMode,
            activeColor: const Color(0xFFE95322),
            onChanged: (val) => setState(() => darkMode = val),
          ),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: notifications,
            activeColor: const Color(0xFFE95322),
            onChanged: (val) => setState(() => notifications = val),
          ),
          const SizedBox(height: 15),
          const Text(
            'Measurement Units:',
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF391713),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: units,
            items: const [
              DropdownMenuItem(value: 'Metric', child: Text('Metric (kg, cm)')),
              DropdownMenuItem(value: 'Imperial', child: Text('Imperial (lb, ft)')),
            ],
            onChanged: (val) => setState(() => units = val!),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'AI Assistant Mode:',
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF391713),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: assistantMode,
            items: const [
              DropdownMenuItem(value: 'Voice-Guided', child: Text('Voice-Guided Mode')),
              DropdownMenuItem(value: 'Text-Only', child: Text('Text-Only Mode')),
              DropdownMenuItem(value: 'Auto', child: Text('Auto Detect Mode')),
            ],
            onChanged: (val) => setState(() => assistantMode = val!),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
