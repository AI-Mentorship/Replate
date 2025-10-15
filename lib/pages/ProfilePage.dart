import 'package:flutter/material.dart';
import '../widgets/BottomNavBar.dart';
import '../data/CalorieData.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0B03A),
      body: SafeArea(
        child: Column(
          children: [
            // Header (photo + name + edit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 38,
                    backgroundImage: NetworkImage(
                      'https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '<Name>',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'League Spartan',
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () {
                          // Navigate to Edit Settings later
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Edit Settings',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: 'League Spartan',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // White background section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 25,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calories Breakdown',
                        style: TextStyle(
                          fontFamily: 'League Spartan',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF391713),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _calorieCard(),
                      const SizedBox(height: 22),

                      const Text(
                        "Today's Progress",
                        style: TextStyle(
                          fontFamily: 'League Spartan',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF391713),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Grid 
                      Expanded(
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.8,
                          children: const [
                            _ProgressCard(
                              title: 'Protein',
                              value: '85g',
                              goal: '120g',
                              color: Color(0xFF00C853),
                              icon: Icons.fitness_center,
                              progress: 0.7,
                            ),
                            _ProgressCard(
                              title: 'Fat',
                              value: '45g',
                              goal: '65g',
                              color: Color(0xFF2979FF),
                              icon: Icons.bolt,
                              progress: 0.6,
                            ),
                            _ProgressCard(
                              title: 'Carbs',
                              value: '120g',
                              goal: '180g',
                              color: Color(0xFFFF6D00),
                              icon: Icons.local_fire_department,
                              progress: 0.67,
                            ),
                            _ProgressCard(
                              title: 'Fiber',
                              value: '18g',
                              goal: '25g',
                              color: Color(0xFF00C853),
                              icon: Icons.apple,
                              progress: 0.72,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 3),
    );
  }

  Widget _calorieCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${CalorieData.current}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF391713),
                  ),
                ),
                TextSpan(
                  text: ' / ${CalorieData.goal} kcal',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: CalorieData.progress,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFFE95322),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MacroStat(color: Colors.green, label: 'Protein', value: '85g'),
              _MacroStat(color: Colors.blue, label: 'Fat', value: '45g'),
              _MacroStat(color: Colors.orange, label: 'Carbs', value: '120g'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _MacroStat({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 6),
        Text(
          '$label $value',
          style: const TextStyle(
            fontFamily: 'League Spartan',
            color: Color(0xFF391713),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final String goal;
  final Color color;
  final IconData icon;
  final double progress;

  const _ProgressCard({
    required this.title,
    required this.value,
    required this.goal,
    required this.color,
    required this.icon,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'League Spartan',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF391713),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$value of $goal',
            style: const TextStyle(
              color: Colors.grey,
              fontFamily: 'League Spartan',
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              color: color,
              backgroundColor: Colors.grey[200],
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
