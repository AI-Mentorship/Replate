import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HealthFitnessGoalsScreen extends StatefulWidget {
  const HealthFitnessGoalsScreen({super.key});

  @override
  State<HealthFitnessGoalsScreen> createState() => _HealthFitnessGoalsScreenState();
}

class _HealthFitnessGoalsScreenState extends State<HealthFitnessGoalsScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController currentWeightController = TextEditingController();
  final TextEditingController weightGoalController = TextEditingController();
  final TextEditingController proteinGoalController = TextEditingController();
  String goalType = 'Maintain';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final row = await supabase
        .from('user_preferences')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (row != null) {
      goalType = row['goal'] ?? 'Maintain';
      caloriesController.text = (row['calorie_target'] ?? '').toString();
      currentWeightController.text = (row['current_weight'] ?? '').toString();
      weightGoalController.text = (row['target_weight'] ?? '').toString();
      proteinGoalController.text = (row['protein_target'] ?? '').toString();
    }

    setState(() => loading = false);
  }

  Future<void> _saveGoals() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = {
      'user_id': user.id,
      'goal': goalType,
      'calorie_target': int.tryParse(caloriesController.text),
      'current_weight': int.tryParse(currentWeightController.text),
      'target_weight': int.tryParse(weightGoalController.text),
      'protein_target': int.tryParse(proteinGoalController.text),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await supabase.from('user_preferences').upsert(data);

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Goals saved!')));
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
          'Health & Fitness Goals',
          style: TextStyle(
            color: Color(0xFF391713),
            fontFamily: 'League Spartan',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveGoals,
            child: const Text(
              'Save',
              style: TextStyle(
                  color: Color(0xFFE95322),
                  fontFamily: 'League Spartan',
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Goal Type:',
            style: TextStyle(
                fontFamily: 'League Spartan',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF391713))),
        DropdownButtonFormField<String>(
          value: goalType,
          items: const [
            DropdownMenuItem(value: 'Maintain', child: Text('Maintain Weight')),
            DropdownMenuItem(value: 'Lose', child: Text('Lose Weight')),
            DropdownMenuItem(value: 'Gain', child: Text('Gain Muscle')),
          ],
          onChanged: (value) => setState(() => goalType = value!),
          decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),
        const SizedBox(height: 20),
        _field('Daily Calorie Target', caloriesController, 'e.g. 2200 kcal'),
        _field('Current Weight (lb)', currentWeightController, 'e.g. 165'),
        _field('Target Weight (lb)', weightGoalController, 'e.g. 155'),
        _field('Protein Goal (g)', proteinGoalController, 'e.g. 120'),
      ],
    );
  }

  Widget _field(String label, TextEditingController c, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'League Spartan',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF391713))),
          const SizedBox(height: 10),
          TextField(
            controller: c,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ),
    );
  }
}
