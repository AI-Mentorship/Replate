import 'package:flutter/material.dart';
import '../screens/ProfilePage.dart';
import '../utils/PageTransition.dart';
import '../pages/HomePage.dart';
import '../pages/PantryPage.dart';
import '../pages/RecipesPage.dart';
import '../pages/SettingsPage.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const BottomNavBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFE95322),
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color(0xFFF3E9B5),
      currentIndex: selectedIndex,
      onTap: (index) {
        if (index == selectedIndex) return; 

        switch (index) {
          case 0: // Home
            Navigator.pushReplacement(
              context,
              createRoute(const HomePage(), fromRight: false),
            );
            break;

          case 1: // Pantry
            Navigator.pushReplacement(
              context,
              createRoute(const PantryPage(), fromRight: index > selectedIndex),
            );
            break;

          case 2: // Recipes
            Navigator.pushReplacement(
              context,
              createRoute(
                const RecipesPage(),
                fromRight: index > selectedIndex,
              ),
            );
            break;

          case 3: // Profile
            Navigator.pushReplacement(
              context,
              createRoute(
                const ProfilePage(),
                fromRight: index > selectedIndex,
              ),
            );
            break;

          case 4: // Settings
            Navigator.pushReplacement(
              context,
              createRoute(
                const SettingsPage(),
                fromRight: index > selectedIndex,
              ),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Pantry'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Recipes'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
