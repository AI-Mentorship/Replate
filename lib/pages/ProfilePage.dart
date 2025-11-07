import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/BottomNavBar.dart';
import '../data/NutritionProvider.dart';
import '../pages/SettingsPage.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  final nutrition = NutritionProvider();
  final supabase = Supabase.instance.client;

  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserData();
  }

  Future<Map<String, dynamic>> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return {'full_name': 'Friend', 'email': ''};

    final row = await supabase
        .from('users')
        .select('full_name, email')
        .eq('user_id', user.id)
        .maybeSingle();

    return {
      'full_name': row?['full_name'] ??
          user.userMetadata?['full_name'] ??
          'Friend',
      'email': row?['email'] ?? user.email ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFE0B03A),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _userFuture,
          builder: (context, snapshot) {
            final name = snapshot.data?['full_name'] ?? 'Friend';
            final email = snapshot.data?['email'] ?? user?.email ?? '';

            return Column(
              children: [
                // HEADER 
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'League Spartan',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontFamily: 'League Spartan',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SettingsPage()),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
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

                // WHITE SECTION 
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
                          horizontal: 25, vertical: 25),
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: nutrition.getTodayNutrition(user?.id ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                                child: Text('No nutrition data available.'));
                          }

                          final data = snapshot.data!;
                          const goal = 2000;
                          final progress =
                              (data['calories'] / goal).clamp(0.0, 1.0);
                          return Column(
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
                              _calorieCard(data, progress, goal),
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
                              Expanded(
                                child: GridView.count(
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 1.8,
                                  children: [
                                    _ProgressCard(
                                      title: 'Protein',
                                      value: '${data['protein']}g',
                                      goal: '120g',
                                      color: const Color(0xFF00C853),
                                      icon: Icons.fitness_center,
                                      progress: (data['protein'] / 120)
                                          .clamp(0.0, 1.0),
                                    ),
                                    _ProgressCard(
                                      title: 'Fat',
                                      value: '${data['fat']}g',
                                      goal: '65g',
                                      color: const Color(0xFF2979FF),
                                      icon: Icons.bolt,
                                      progress: (data['fat'] / 65)
                                          .clamp(0.0, 1.0),
                                    ),
                                    _ProgressCard(
                                      title: 'Carbs',
                                      value: '${data['carbs']}g',
                                      goal: '180g',
                                      color: const Color(0xFFFF6D00),
                                      icon: Icons.local_fire_department,
                                      progress: (data['carbs'] / 180)
                                          .clamp(0.0, 1.0),
                                    ),
                                    _ProgressCard(
                                      title: 'Fiber',
                                      value: '${data['fiber']}g',
                                      goal: '25g',
                                      color: const Color(0xFF9C27B0),
                                      icon: Icons.apple,
                                      progress: (data['fiber'] / 25)
                                          .clamp(0.0, 1.0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 3),
    );
  }

  Widget _calorieCard(Map<String, dynamic> data, double progress, int goal) {
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
            TextSpan(children: [
              TextSpan(
                text: '${data['calories']}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF391713),
                ),
              ),
              TextSpan(
                text: ' / $goal kcal',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFFE95322),
              minHeight: 8,
            ),
          ),
        ],
      ),
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
          Row(children: [
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
          ]),
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
