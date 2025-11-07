import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DietaryPreferencesScreen extends StatefulWidget {
  const DietaryPreferencesScreen({super.key});

  @override
  State<DietaryPreferencesScreen> createState() => _DietaryPreferencesScreenState();
}

class _DietaryPreferencesScreenState extends State<DietaryPreferencesScreen> {
  final supabase = Supabase.instance.client;
  bool vegetarian = false;
  bool vegan = false;
  bool pescatarian = false;
  bool glutenFree = false;
  bool dairyFree = false;
  bool nutAllergy = false;
  final Map<String, bool> restrictionDays = {
    'Mon': false,
    'Tue': false,
    'Wed': false,
    'Thu': false,
    'Fri': false,
    'Sat': false,
    'Sun': false,
  };
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final row = await supabase
        .from('user_preferences')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (row != null) {
      final diet = row['diet_type'] ?? '';
      vegetarian = diet == 'Vegetarian';
      vegan = diet == 'Vegan';
      pescatarian = diet == 'Pescatarian';

      final restrictions = (row['restrictions'] ?? []) as List;
      glutenFree = restrictions.contains('Gluten-Free');
      dairyFree = restrictions.contains('Dairy-Free');
      nutAllergy = restrictions.contains('Nut Allergy');

      if (row['restriction_days'] != null) {
        for (var day in restrictionDays.keys) {
          restrictionDays[day] = (row['restriction_days'] as List).contains(day);
        }
      }
    }

    setState(() => loading = false);
  }

  Future<void> _saveSettings() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    String? diet;
    if (vegetarian) diet = 'Vegetarian';
    if (vegan) diet = 'Vegan';
    if (pescatarian) diet = 'Pescatarian';

    final restrictions = [
      if (glutenFree) 'Gluten-Free',
      if (dairyFree) 'Dairy-Free',
      if (nutAllergy) 'Nut Allergy',
    ];

    final data = {
      'user_id': user.id,
      'diet_type': diet ?? 'None',
      'restrictions': restrictions,
      'restriction_days': restrictionDays.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await supabase.from('user_preferences').upsert(data);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dietary preferences saved!')),
      );
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
          'Dietary Preferences',
          style: TextStyle(
            color: Color(0xFF391713),
            fontFamily: 'League Spartan',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFFE95322),
                fontFamily: 'League Spartan',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Diet Types:',
            style: TextStyle(
                fontFamily: 'League Spartan',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF391713))),
        _check('Vegetarian', vegetarian, (v) => setState(() => vegetarian = v)),
        _check('Vegan', vegan, (v) => setState(() => vegan = v)),
        _check('Pescatarian', pescatarian, (v) => setState(() => pescatarian = v)),
        const SizedBox(height: 12),
        const Text('Allergies & Restrictions:',
            style: TextStyle(
                fontFamily: 'League Spartan',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF391713))),
        _check('Gluten-Free', glutenFree, (v) => setState(() => glutenFree = v)),
        _check('Dairy-Free', dairyFree, (v) => setState(() => dairyFree = v)),
        _check('Nut Allergy', nutAllergy, (v) => setState(() => nutAllergy = v)),
        const SizedBox(height: 16),
        const Text('Custom Restriction Days:',
            style: TextStyle(
                fontFamily: 'League Spartan',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF391713))),
        Wrap(
          spacing: 8,
          children: restrictionDays.keys.map((day) {
            final selected = restrictionDays[day]!;
            return FilterChip(
              label: Text(day),
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF391713),
                fontFamily: 'League Spartan',
              ),
              selected: selected,
              selectedColor: const Color(0xFFE95322),
              onSelected: (val) => setState(() => restrictionDays[day] = val),
            );
          }).toList(),
        ),
      ],
    );
  }

  CheckboxListTile _check(String title, bool val, Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: val,
      activeColor: const Color(0xFFE95322),
      onChanged: (v) => onChanged(v!),
    );
  }
}
