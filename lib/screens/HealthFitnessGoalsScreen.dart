import 'package:flutter/material.dart';

class HealthFitnessGoalsScreen extends StatefulWidget {
  const HealthFitnessGoalsScreen({super.key});

  @override
  State<HealthFitnessGoalsScreen> createState() => _HealthFitnessGoalsScreenState();
}

class _HealthFitnessGoalsScreenState extends State<HealthFitnessGoalsScreen> {
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController currentWeightController = TextEditingController();
  final TextEditingController weightGoalController = TextEditingController();
  final TextEditingController proteinGoalController = TextEditingController();
  String goalType = 'Maintain';

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
            'Current Weight (lb):',
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF391713),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: currentWeightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g. 165 lb',
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
            'Protein Goal (g):',
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF391713),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: proteinGoalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g. 120 g',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
