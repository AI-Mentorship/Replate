import 'package:flutter/material.dart';
import '../widgets/BottomNavBar.dart';
import '../screens/CookingAssistantScreen.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  String selectedTab = "Saved"; // default tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0B03A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            SizedBox(
              width: double.infinity,
              height: 64,
              child: Center(
                child: Text(
                  'Recipes',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'League Spartan',
                  ),
                ),
              ),
            ),

            // White background
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Tabs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTabButton("Discover"),
                          _buildTabButton("Saved"),
                          _buildTabButton("Upload"),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Divider(color: Colors.grey.shade300, thickness: 1),

                      // Content based on selected tab
                      Expanded(child: _buildTabContent()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Nav Bar
      bottomNavigationBar: const BottomNavBar(selectedIndex: 2),
    );
  }

  // Tabs UI
  Widget _buildTabButton(String label) {
  final bool isSelected = selectedTab == label;
  final screenWidth = MediaQuery.of(context).size.width;
  return GestureDetector(
    onTap: () => setState(() => selectedTab = label),
    child: Container(
      width: screenWidth / 3.5, 
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.025),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE95322) : const Color(0xFFFFE6DC),
        borderRadius: BorderRadius.circular(25),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF391713),
          fontFamily: 'League Spartan',
          fontWeight: FontWeight.w600,
          fontSize: screenWidth * 0.04,
        ),
      ),
    ),
  );
}

  // Handles what shows for each tab
  Widget _buildTabContent() {
    if (selectedTab == "Discover") {
      return const Center(
        child: Text(
          "Browse trending dishes and new ideas!",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF391713),
            fontFamily: 'League Spartan',
            fontSize: 16,
          ),
        ),
      );
    } else if (selectedTab == "Upload") {
      return const Center(
        child: Text(
          "Upload YouTube or TikTok recipe links here!",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF391713),
            fontFamily: 'League Spartan',
            fontSize: 16,
          ),
        ),
      );
    } else {
      // Saved tab
      return ListView(
        children: [
          _RecipeItem(
            imageUrl:
                'https://upload.wikimedia.org/wikipedia/commons/3/39/Chicken_Curry.jpg',
            title: 'Chicken Curry',
            details: '500 Cal · 30 Min',
            steps: const [
              'Heat oil in a pan and sauté onions until golden.',
              'Add ginger garlic paste and stir for 1 minute.',
              'Add chicken and cook until lightly browned.',
              'Pour in curry sauce and simmer for 20 minutes.',
              'Serve hot with rice or naan.',
            ],
          ),
          _RecipeItem(
            imageUrl:
                'https://upload.wikimedia.org/wikipedia/commons/5/57/Veggie_burger_%281%29.jpg',
            title: 'Bean and Vegetable Burger',
            details: '470 Cal · 20 Min',
            steps: const [
              'Mash beans and mix with chopped veggies.',
              'Add spices and breadcrumbs, form patties.',
              'Grill each side for 3–4 minutes.',
              'Serve on buns with toppings of choice.',
            ],
          ),
          _RecipeItem(
            imageUrl:
                'https://upload.wikimedia.org/wikipedia/commons/4/45/Coffee_Latte.jpg',
            title: 'Coffee Latte',
            details: '170 Cal · 10 Min',
            steps: const [
              'Heat 200 ml of milk until steaming, not boiling.',
              'Pull a single espresso shot into a cup.',
              'Pour 50 milliliters of hot water over the grounds in a slow circular motion. Let it sit for 30 to 45 seconds to allow the coffee to bloom.',
              'Froth the milk to a silky microfoam.',
              'Gently pour milk over espresso, then top with foam.',
            ],
          ),
          _RecipeItem(
            imageUrl:
                'https://upload.wikimedia.org/wikipedia/commons/0/02/Strawberry_cheesecake.jpg',
            title: 'Strawberry Cheesecake',
            details: '150 Cal · 30 Min',
            steps: const [
              'Crush biscuits and mix with melted butter.',
              'Press mixture into pan and chill.',
              'Blend cream cheese, sugar, and vanilla until smooth.',
              'Add whipped cream and spread over crust.',
              'Top with strawberry glaze and chill for 4 hours.',
            ],
          ),
        ],
      );
    }
  }
}

// Recipe item with navigation to cooking assistant
class _RecipeItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String details;
  final List<String> steps;

  const _RecipeItem({
    required this.imageUrl,
    required this.title,
    required this.details,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CookingAssistantScreen(recipeTitle: title, steps: steps),
              ),
            );
          },
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF391713),
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            details,
            style: const TextStyle(
              color: Colors.grey,
              fontFamily: 'League Spartan',
              fontSize: 14,
            ),
          ),
        ),
        Divider(color: Colors.grey.shade300, thickness: 1),
      ],
    );
  }
}
