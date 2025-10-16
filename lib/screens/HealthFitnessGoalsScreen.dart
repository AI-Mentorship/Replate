import 'package:flutter/material.dart';

class HealthFitnessGoalsScreen extends StatefulWidget {
  const HealthFitnessGoalsScreen({super.key});

  @override
  State<HealthFitnessGoalsScreen> createState() => _HealthFitnessGoalsScreenState();
}

class _HealthFitnessGoalsScreenState extends State<HealthFitnessGoalsScreen> {
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController weightGoalController = TextEditingController();
  String goalType = 'Maintain';
  double activityLevel = 1.2;

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
          'Health & Fitness Goals',
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
            'Goal Type:',
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF391713),
            ),
          ),
          DropdownButtonFormField<String>(
            value: goalType,
            items: const [
              DropdownMenuItem(value: 'Maintain', child: Text('Maintain Weight')),
              DropdownMenuItem(value: 'Lose', child: Text('Lose Weight')),
              DropdownMenuItem(value: 'Gain', child: Text('Gain Muscle')),
            ],
            onChanged: (value) => setState(() => goalType = value!),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Daily Calorie Target:',
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF391713),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: caloriesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g. 2200 kcal',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Target Weight (lb):',
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF391713),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: weightGoalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g. 155 lb',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Activity Level:',
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF391713),
            ),
          ),
          DropdownButtonFormField<double>(
            value: activityLevel,
            items: const [
              DropdownMenuItem(value: 1.2, child: Text('Sedentary (little or no exercise)')),
              DropdownMenuItem(value: 1.375, child: Text('Lightly Active (1–3 days/week)')),
              DropdownMenuItem(value: 1.55, child: Text('Moderately Active (3–5 days/week)')),
              DropdownMenuItem(value: 1.725, child: Text('Very Active (6–7 days/week)')),
            ],
            onChanged: (val) => setState(() => activityLevel = val!),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
