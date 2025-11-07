import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../data/SupabaseRepo.dart';
import '../widgets/BottomNavBar.dart';
import '../screens/RecipeOverviewScreen.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  String selectedTab = "Discover";
  final repo = SupabaseRepo();
  late Future<List<dynamic>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    _recipesFuture = repo.fetchRecipes(userId ?? '');
  }

  Future<Map<String, dynamic>> _mockParseRecipe(String url) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      "title": "Shrimp Pasta",
      "description": "Creamy garlic shrimp pasta with herbs and parmesan.",
      "steps": [
        "Boil pasta until al dente.",
        "Sauté shrimp in butter and garlic.",
        "Add cream and parmesan, stir until thickened.",
        "Toss pasta with sauce and garnish with parsley."
      ],
      "ingredients": [
        "200g spaghetti",
        "250g shrimp",
        "3 cloves garlic",
        "1 cup heavy cream",
        "2 tbsp butter",
        "Parmesan and parsley"
      ]
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0B03A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 64,
              child: Center(
                child: Text(
                  'Recipes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'League Spartan',
                  ),
                ),
              ),
            ),
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
                    children: [
                      _buildTabRow(context),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.shade300, thickness: 1),
                      const SizedBox(height: 10),
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

  Widget _buildTabRow(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTabButton("Discover", screenWidth),
        _buildTabButton("Saved", screenWidth),
        _buildTabButton("Upload", screenWidth),
      ],
    );
  }

  Widget _buildTabButton(String label, double screenWidth) {
    final bool isSelected = selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = label),
      child: Container(
        width: screenWidth / 3.8,
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFFE95322) : const Color(0xFFFFE6DC),
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF391713),
            fontFamily: 'League Spartan',
            fontWeight: FontWeight.w600,
            fontSize: screenWidth * 0.038,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (selectedTab == "Discover") {
      return _buildDiscoverTab();
    } else if (selectedTab == "Upload") {
      return _buildUploadTab();
    } else {
      return _buildSavedTab();
    }
  }

  Widget _buildDiscoverTab() {
    final List<Map<String, dynamic>> recipes = [
      {
        "title": "Garlic Butter Shrimp",
        "desc": "Juicy shrimp cooked in garlic butter and herbs.",
        "icon": Icons.restaurant_menu,
        "ingredients": [
          "1 lb large shrimp, peeled and deveined",
          "3 tbsp unsalted butter",
          "4 cloves garlic, minced",
          "1 tbsp lemon juice",
          "Salt and black pepper to taste",
          "Fresh parsley for garnish"
        ],
        "steps": [
          "Melt butter in a skillet over medium heat.",
          "Add minced garlic and sauté until fragrant.",
          "Add shrimp, season with salt and pepper, and cook 2–3 minutes per side.",
          "Drizzle with lemon juice, garnish with parsley, and serve immediately."
        ],
        "nutrition": {
          "Calories": "320 kcal",
          "Protein": "28g",
          "Carbs": "3g",
          "Fat": "20g"
        },
        "time": "15 min"
      },
      {
        "title": "Spaghetti Pomodoro",
        "desc": "Classic Italian tomato pasta with basil.",
        "icon": Icons.local_dining,
        "ingredients": [
          "8 oz spaghetti",
          "2 tbsp olive oil",
          "3 cloves garlic, minced",
          "2 cups crushed tomatoes",
          "1/4 cup fresh basil leaves",
          "Salt and pepper to taste",
          "Parmesan for topping"
        ],
        "steps": [
          "Cook spaghetti in salted boiling water until al dente.",
          "In a pan, heat olive oil and sauté garlic until golden.",
          "Add crushed tomatoes, season with salt and pepper, and simmer 10 minutes.",
          "Toss cooked pasta in sauce, mix in basil, and top with parmesan."
        ],
        "nutrition": {
          "Calories": "410 kcal",
          "Protein": "13g",
          "Carbs": "60g",
          "Fat": "12g"
        },
        "time": "25 min"
      },
      {
        "title": "Grilled Chicken Salad",
        "desc": "Healthy chicken salad with crisp veggies.",
        "icon": Icons.eco,
        "ingredients": [
          "1 boneless chicken breast",
          "2 cups mixed greens",
          "1/2 cucumber, sliced",
          "1/2 cup cherry tomatoes, halved",
          "2 tbsp olive oil",
          "1 tbsp balsamic vinegar",
          "Salt and pepper to taste"
        ],
        "steps": [
          "Season chicken breast with salt and pepper, then grill until cooked through.",
          "Let it rest, then slice into strips.",
          "In a bowl, toss greens, cucumber, and tomatoes with olive oil and vinegar.",
          "Top with sliced chicken and serve."
        ],
        "nutrition": {
          "Calories": "350 kcal",
          "Protein": "32g",
          "Carbs": "9g",
          "Fat": "20g"
        },
        "time": "20 min"
      },
      {
        "title": "Beef Stir Fry",
        "desc": "Savory beef and vegetables tossed in soy glaze.",
        "icon": Icons.ramen_dining,
        "ingredients": [
          "1/2 lb flank steak, thinly sliced",
          "1 cup broccoli florets",
          "1 red bell pepper, sliced",
          "2 tbsp soy sauce",
          "1 tbsp oyster sauce",
          "1 tbsp sesame oil",
          "1 tsp cornstarch mixed with 2 tbsp water"
        ],
        "steps": [
          "Heat sesame oil in a wok over high heat.",
          "Add beef and stir-fry for 2–3 minutes until browned.",
          "Add broccoli and bell pepper, cook for another 3–4 minutes.",
          "Pour in soy and oyster sauces, add cornstarch slurry, and stir until thickened."
        ],
        "nutrition": {
          "Calories": "420 kcal",
          "Protein": "30g",
          "Carbs": "15g",
          "Fat": "26g"
        },
        "time": "25 min"
      },
    ];

    return ListView.separated(
      itemCount: recipes.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.grey.shade300, thickness: 1),
      itemBuilder: (context, i) {
        final r = recipes[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFE95322).withOpacity(0.1),
            child: Icon(r['icon'], color: const Color(0xFFE95322)),
          ),
          title: Text(
            r['title'],
            style: const TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w600,
              color: Color(0xFF391713),
              fontSize: 17,
            ),
          ),
          subtitle: Text(
            r['desc'],
            style: const TextStyle(
              fontFamily: 'League Spartan',
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeOverviewScreen(
                title: r['title'],
                imageUrl: '',
                description: r['desc'],
                details: "${r['nutrition']?['Calories']}  ${r['time']}",
                steps: List<String>.from(r['steps']),
                ingredients: List<String>.from(r['ingredients']),
                nutrition: Map<String, String>.from(r['nutrition']),
                time: r['time'],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadTab() {
    final TextEditingController _urlController = TextEditingController();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Paste a recipe link below:",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF391713),
            fontFamily: 'League Spartan',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: "https://example.com/recipe",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final recipe = await _mockParseRecipe(_urlController.text.trim());
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeOverviewScreen(
                  title: recipe['title'],
                  imageUrl: '',
                  description: recipe['description'],
                  details: '650 Cal  25 Min',
                  steps: List<String>.from(recipe['steps']),
                  ingredients: List<String>.from(recipe['ingredients']),
                  nutrition: const {
                    'Calories': '650 kcal',
                    'Protein': '45g',
                    'Carbs': '55g',
                    'Fat': '22g',
                  },
                  time: '25 min',
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE95322),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
  }
  Widget _buildSavedTab() {
    return FutureBuilder<List<dynamic>>(
      future: _recipesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE95322)));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text("Error loading recipes: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No saved recipes yet.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF391713),
                fontFamily: 'League Spartan',
                fontSize: 16,
              ),
            ),
          );
        }

        final recipes = snapshot.data!;
        return ListView.separated(
          itemCount: recipes.length,
          separatorBuilder: (_, __) =>
              Divider(color: Colors.grey.shade300, thickness: 1),
          itemBuilder: (context, i) {
            final recipe = recipes[i];

            List<String> parseList(dynamic data) {
              if (data == null) return [];
              try {
                if (data is List) return data.map((e) => e.toString()).toList();
                if (data is String) {
                  final decoded = jsonDecode(data);
                  if (decoded is List) return decoded.map((e) => e.toString()).toList();
                  if (decoded is Map) return decoded.values.map((e) => e.toString()).toList();
                }
                if (data is Map) return data.values.map((e) => e.toString()).toList();
              } catch (_) {}
              return data
                  .toString()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
            }

            final ingredients = parseList(recipe['ingredients']);
            final steps = parseList(recipe['steps']);

            Map<String, String> nutrition = {
              'Calories': '—',
              'Protein': '—',
              'Carbs': '—',
              'Fat': '—',
            };
            if (recipe['nutrition'] != null) {
              try {
                if (recipe['nutrition'] is Map) {
                  nutrition = (recipe['nutrition'] as Map)
                      .map((k, v) => MapEntry(k.toString(), v.toString()));
                } else if (recipe['nutrition'] is String) {
                  final parsed = jsonDecode(recipe['nutrition']);
                  if (parsed is Map) {
                    nutrition = parsed.map((k, v) => MapEntry(k.toString(), v.toString()));
                  }
                }
              } catch (_) {}
            }

            final cal = nutrition['Calories'] ?? '';
            final time = (recipe['time'] ?? '').toString();
            final details =
                (cal.isNotEmpty && cal != '—' && time.isNotEmpty && time != '—')
                    ? "$cal  $time"
                    : null; 

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFFE95322).withOpacity(0.1),
                  child: const Icon(Icons.bookmark, color: Color(0xFFE95322)),
                ),
                title: Text(
                  recipe['title'] ?? 'Untitled',
                  style: const TextStyle(
                    fontFamily: 'League Spartan',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF391713),
                    fontSize: 17,
                  ),
                ),
                subtitle: details != null
                    ? Text(
                        details,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'League Spartan',
                          fontSize: 13,
                        ),
                      )
                    : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecipeOverviewScreen(
                      title: recipe['title'] ?? 'Untitled',
                      imageUrl: '',
                      description:
                          recipe['description'] ?? 'A saved recipe.',
                      details: details ?? '',
                      steps: steps,
                      ingredients: ingredients.isNotEmpty
                          ? ingredients
                          : ['No ingredients available'],
                      nutrition: nutrition,
                      time: time,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
