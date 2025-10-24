import 'package:flutter/material.dart';
import '../widgets/BottomNavBar.dart';
import '../screens/RecipeOverviewScreen.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  String selectedTab = "Saved"; // default tab

  // Mock backend function
  Future<Map<String, dynamic>> _mockParseRecipe(String url) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      "title": "Imported Recipe from $url",
      "steps": [
        "Step 1: Preheat your pan or oven.",
        "Step 2: Prepare ingredients as listed.",
        "Step 3: Follow the cooking instructions from the video.",
        "Step 4: Serve and enjoy!",
      ],
    };
  }

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
              child: const Center(
                child: Text(
                  'Recipes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'League Spartan',
                  ),
                ),
              ),
            ),

            // White Section
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
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

                      // Tab content
                      Expanded(child: _buildTabContent()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 2),
    );
  }

  // Tab Buttons
  Widget _buildTabButton(String label) {
    final bool isSelected = selectedTab == label;
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = label),
      child: Container(
        width: screenWidth / 3.5,
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.025),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFFE95322) : const Color(0xFFFFE6DC),
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

  // Tab content
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
      final TextEditingController _urlController = TextEditingController();

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Paste a recipe link below:",
            style: TextStyle(
              color: Color(0xFF391713),
              fontFamily: 'League Spartan',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: "https://example.com/recipe",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final url = _urlController.text.trim();
              if (url.isEmpty) return;

              final recipe = await _mockParseRecipe(url);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeOverviewScreen(
                    title: recipe['title'],
                    imageUrl:
                        'https://images.unsplash.com/photo-1604908813191-fd9334a7e1d4?auto=format&fit=crop&w=600&q=60',
                    description: 'Auto-generated recipe preview.',
                    details: '500 Cal · 30 Min',
                    steps: List<String>.from(recipe['steps']),
                    ingredients: const [
                      '1 tbsp oil',
                      '2 onions',
                      '500g chicken',
                      '1 cup curry sauce'
                    ],
                    nutrition: const {
                      'Calories': '500 kcal',
                      'Protein': '35g',
                      'Carbs': '40g',
                      'Fat': '18g'
                    },
                    time: '30 min',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE95322),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            ),
            child: const Text(
              "Generate Recipe",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'League Spartan',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    } else {
      // Saved Recipes Tab
      return ListView(
        children: const [
          _RecipeItem(
            imageUrl:
                'https://images.unsplash.com/photo-1604908813191-fd9334a7e1d4?auto=format&fit=crop&w=600&q=60',
            title: 'Chicken Curry',
            details: '500 Cal · 30 Min',
            steps: [
              'Heat oil in a pan and sauté onions until golden.',
              'Add ginger garlic paste and stir for 1 minute.',
              'Add chicken and cook until lightly browned.',
              'Pour in curry sauce and simmer for 20 minutes.',
              'Serve hot with rice or naan.',
            ],
            ingredients: [
              '1 tbsp oil',
              '2 onions',
              '500g chicken',
              '1 cup curry sauce'
            ],
            nutrition: {
              'Calories': '500 kcal',
              'Protein': '35g',
              'Carbs': '40g',
              'Fat': '18g'
            },
            time: '30 min',
          ),
          _RecipeItem(
            imageUrl:
                'https://images.unsplash.com/photo-1601050690597-4fbdc41c69c4?auto=format&fit=crop&w=600&q=60',
            title: 'Bean and Vegetable Burger',
            details: '470 Cal · 20 Min',
            steps: [
              'Mash beans and mix with chopped veggies.',
              'Add spices and breadcrumbs, form patties.',
              'Grill each side for 3–4 minutes.',
              'Serve on buns with toppings of choice.',
            ],
            ingredients: [
              '1 can kidney beans',
              '1 carrot (grated)',
              '½ onion (chopped)',
              '½ cup breadcrumbs'
            ],
            nutrition: {
              'Calories': '470 kcal',
              'Protein': '22g',
              'Carbs': '50g',
              'Fat': '15g'
            },
            time: '20 min',
          ),
          _RecipeItem(
            imageUrl:
                'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=600&q=60',
            title: 'Coffee Latte',
            details: '170 Cal · 10 Min',
            steps: [
              'Heat 200 ml of milk until steaming, not boiling.',
              'Pull a single espresso shot into a cup.',
              'Pour 50 ml of hot water over the grounds slowly.',
              'Froth the milk to a silky microfoam.',
              'Gently pour milk over espresso, then top with foam.',
            ],
            ingredients: [
              '200 ml milk',
              '1 espresso shot',
              '50 ml hot water'
            ],
            nutrition: {
              'Calories': '170 kcal',
              'Protein': '8g',
              'Carbs': '12g',
              'Fat': '7g'
            },
            time: '10 min',
          ),
          _RecipeItem(
            imageUrl:
                'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=600&q=60',
            title: 'Strawberry Cheesecake',
            details: '150 Cal · 30 Min',
            steps: [
              'Crush biscuits and mix with melted butter.',
              'Press mixture into pan and chill.',
              'Blend cream cheese, sugar, and vanilla until smooth.',
              'Add whipped cream and spread over crust.',
              'Top with strawberry glaze and chill for 4 hours.',
            ],
            ingredients: [
              '1 cup biscuits (crushed)',
              '3 tbsp melted butter',
              '250g cream cheese',
              '½ cup sugar',
              'Strawberry glaze'
            ],
            nutrition: {
              'Calories': '150 kcal',
              'Protein': '4g',
              'Carbs': '18g',
              'Fat': '7g'
            },
            time: '30 min',
          ),
        ],
      );
    }
  }
}

class _RecipeItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String details;
  final List<String> steps;
  final List<String> ingredients;
  final Map<String, String> nutrition;
  final String time;

  const _RecipeItem({
    required this.imageUrl,
    required this.title,
    required this.details,
    required this.steps,
    required this.ingredients,
    required this.nutrition,
    required this.time,
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
                builder: (_) => RecipeOverviewScreen(
                  title: title,
                  imageUrl: imageUrl,
                  details: details,
                  description: "A delicious recipe for $title.",
                  steps: steps,
                  ingredients: ingredients,
                  nutrition: nutrition,
                  time: time,
                ),
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
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey),
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
