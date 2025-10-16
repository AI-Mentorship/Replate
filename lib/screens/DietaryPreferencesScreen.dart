import 'package:flutter/material.dart';

class DietaryPreferencesScreen extends StatefulWidget {
  const DietaryPreferencesScreen({super.key});

  @override
  State<DietaryPreferencesScreen> createState() => _DietaryPreferencesScreenState();
}

class _DietaryPreferencesScreenState extends State<DietaryPreferencesScreen> {
  bool vegetarian = false;
  bool vegan = false;
  bool pescatarian = false;

  bool glutenFree = false;
  bool dairyFree = false;
  bool nutAllergy = false;

  bool autoSubstitute = true;

  final Map<String, bool> restrictionDays = {
    'Mon': false,
    'Tue': false,
    'Wed': false,
    'Thu': false,
    'Fri': false,
    'Sat': false,
    'Sun': false,
  };

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
          'Dietary Preferences',
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
          const Text(
            'Diet Types:',
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF391713),
            ),
          ),
          CheckboxListTile(
            title: const Text('Vegetarian'),
            value: vegetarian,
            activeColor: const Color(0xFFE95322),
            onChanged: (val) => setState(() => vegetarian = val!),
          ),
          CheckboxListTile(
            title: const Text('Vegan'),
            value: vegan,
            activeColor: const Color(0xFFE95322),
            onChanged: (val) => setState(() => vegan = val!),
          ),
          CheckboxListTile(
            title: const Text('Pescatarian'),
            value: pescatarian,
            activeColor: const Color(0xFFE95322),
            onChanged: (val) => setState(() => pescatarian = val!),
          ),

          const SizedBox(height: 12),
          const Text(
            'Allergies & Restrictions:',
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF391713),
            ),
          ),
          CheckboxListTile(
            title: const Text('Gluten-Free'),
            value: glutenFree,
            activeColor: const Color(0xFFE95322),
            onChanged: (val) => setState(() => glutenFree = val!),
          ),
          CheckboxListTile(
            title: const Text('Dairy-Free'),
            value: dairyFree,
            activeColor: const Color(0xFFE95322),
            onChanged: (val) => setState(() => dairyFree = val!),
          ),
          CheckboxListTile(
            title: const Text('Nut Allergy'),
            value: nutAllergy,
            activeColor: const Color(0xFFE95322),
            onChanged: (val) => setState(() => nutAllergy = val!),
          ),

          const SizedBox(height: 16),
          const Text(
            'Custom Restriction Days:',
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF391713),
            ),
          ),
          const SizedBox(height: 8),
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

          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Auto Suggest Ingredient Substitutes'),
            subtitle: const Text('Automatically replace restricted items in recipes'),
            value: autoSubstitute,
            activeColor: const Color(0xFFE95322),
            onChanged: (val) => setState(() => autoSubstitute = val),
          ),
        ],
      ),
    );
  }
}
