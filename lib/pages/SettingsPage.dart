import 'package:flutter/material.dart';
import '../widgets/BottomNavBar.dart';
import '../utils/PageTransition.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          'Settings',
          style: TextStyle(
            color: Color(0xFF391713),
            fontFamily: 'League Spartan',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _settingsCard(
              context,
              title: 'Dietary Restrictions',
              subtitle: 'Allergies, dietary preferences, and restrictions',
              icon: Icons.shield_outlined,
              color: const Color(0xFF00C853),
              destination: null, 
            ),
            const SizedBox(height: 15),
            _settingsCard(
              context,
              title: 'Fitness Goals',
              subtitle: 'Weight goals and activity targets',
              icon: Icons.fitness_center_outlined,
              color: const Color(0xFF2979FF),
              destination: null, 
            ),
            const SizedBox(height: 15),
            _settingsCard(
              context,
              title: 'Personal Settings',
              subtitle: 'Units, notifications, and preferences',
              icon: Icons.settings_outlined,
              color: const Color(0xFFFF6D00),
              destination: null, 
            ),
          ],
        ),
      ),

      bottomNavigationBar: const BottomNavBar(selectedIndex: 4),
    );
  }

  Widget _settingsCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    Widget? destination, 
  }) {
    return GestureDetector(
      onTap: destination != null
          ? () => Navigator.push(context, createRoute(destination, fromRight: true))
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title page coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'League Spartan',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF391713),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontFamily: 'League Spartan',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
