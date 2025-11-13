import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
  final supabase = Supabase.instance.client;
  String units = 'Imperial';
  String assistantMode = 'Voice-Guided';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final row = await supabase.from('user_settings').select().eq('user_id', user.id).maybeSingle();

    if (row != null) {
      units = row['units'] ?? 'Imperial';
      assistantMode = row['assistant_mode'] ?? 'Voice-Guided';
    }
    setState(() => loading = false);
  }

  Future<void> _savePrefs() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = {
      'user_id': user.id,
      'units': units,
      'assistant_mode': assistantMode,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await supabase.from('user_settings').upsert(data);

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('App preferences saved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE95322))),
      );
    }

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
        actions: [
          TextButton(
            onPressed: _savePrefs,
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFFE95322), fontFamily: 'League Spartan', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Measurement Units:',
              style: TextStyle(fontFamily: 'League Spartan', fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF391713))),
          DropdownButtonFormField<String>(
            value: units,
            items: const [
              DropdownMenuItem(value: 'Imperial', child: Text('Imperial (lb, ft)')),
              DropdownMenuItem(value: 'Metric', child: Text('Metric (kg, cm)')),
            ],
            onChanged: (val) => setState(() => units = val!),
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 25),
          const Text('AI Assistant Mode:',
              style: TextStyle(fontFamily: 'League Spartan', fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF391713))),
          DropdownButtonFormField<String>(
            value: assistantMode,
            items: const [
              DropdownMenuItem(value: 'Voice-Guided', child: Text('Voice-Guided Mode')),
              DropdownMenuItem(value: 'Text-Only', child: Text('Text-Only Mode')),
              DropdownMenuItem(value: 'Auto', child: Text('Auto Detect Mode')),
            ],
            onChanged: (val) => setState(() => assistantMode = val!),
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ),
    );
  }
}
