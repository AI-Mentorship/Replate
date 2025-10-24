import 'package:flutter/material.dart';
import 'PantryPage.dart';
import 'RecipesPage.dart';
import 'SettingsPage.dart';
import '../widgets/BottomNavBar.dart';
import '../utils/PageTransition.dart';
import '../data/CalorieData.dart';
import '../pages/ProfilePage.dart';
import '../screens/RecipeOverviewScreen.dart';
import '../screens/GroceryListScreen.dart';
import '../utils/CameraHelper.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFE0B03A),
      drawer: _buildSideMenu(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Hi, <Name> 👋",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'League Spartan',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: screenWidth * 0.08,
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                ],
              ),
            ),

            // Expanded White Section
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Meals",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontFamily: 'League Spartan',
                          color: const Color(0xFF391713),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Grocery + Calorie Cards
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final totalPadding = constraints.maxWidth * 0.06;
                          final cardWidth = (constraints.maxWidth - totalPadding) / 2;
                          final cardHeight = screenWidth * 0.45;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    createRoute(
                                      const GroceryListScreen(),
                                      fromRight: true,
                                    ),
                                  );
                                },
                                child: _mealCard(
                                  title: "Grocery List",
                                  subtitle: "View or generate items",
                                  imageUrl:
                                      "https://images.unsplash.com/photo-1601050690597-02fae3f165a5?auto=format&fit=crop&w=400&q=80",
                                  width: cardWidth,
                                  height: cardHeight,
                                ),
                              ),
                              _calorieCard(context, cardWidth, cardHeight),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 25),

                      // Scan Fridge Button
                      Center(
                        child: SizedBox(
                          width: screenWidth * 0.75,
                          height: screenHeight * 0.065,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE95322),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () async {
                              final imageFile = await CameraHelper.pickImageFromCamera();
                              if (imageFile != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Photo captured successfully!")),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("No photo captured.")),
                                );
                              }
                            },
                            child: Text(
                              "+ Scan Fridge",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.05,
                                fontFamily: 'League Spartan',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),
                      // Quick Recipes
                      Text(
                        "Quick Recipes",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontFamily: 'League Spartan',
                          color: const Color(0xFF391713),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),

                      SizedBox(
                        height: 200,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _recipeCard(
                              context,
                              title: "Pasta Casera",
                              author: "By Troyan Smith",
                              rating: "4.7",
                              imageUrl:
                                  "https://upload.wikimedia.org/wikipedia/commons/b/bc/Spaghetti_aglio_e_olio_%28homemade%29.jpg",
                              ingredients: const [
                                "Spaghetti",
                                "Olive Oil",
                                "Garlic",
                                "Salt",
                                "Parsley",
                                "Parmesan"
                              ],
                              steps: const [
                                "Boil spaghetti until al dente.",
                                "Heat olive oil and garlic in a pan.",
                                "Toss pasta with oil, salt, and parsley.",
                                "Top with parmesan and serve hot.",
                              ],
                              nutrition: const {
                                "Calories": "420 kcal",
                                "Protein": "12g",
                                "Fat": "14g",
                                "Carbs": "65g"
                              },
                              time: "15 mins",
                              cardWidth: screenWidth * 0.45,
                              cardHeight: screenHeight * 0.22,
                            ),
                            const SizedBox(width: 15),
                            _recipeCard(
                              context,
                              title: "Pasta Carbonara",
                              author: "By Niki Samantha",
                              rating: "4.5",
                              imageUrl:
                                  "https://upload.wikimedia.org/wikipedia/commons/f/f3/Spaghetti_alla_Carbonara_%28cropped%29.jpg",
                              ingredients: const [
                                "Spaghetti",
                                "Eggs",
                                "Parmesan",
                                "Pancetta",
                                "Black Pepper"
                              ],
                              steps: const [
                                "Cook spaghetti until al dente.",
                                "Fry pancetta until crisp.",
                                "Mix eggs with parmesan and pepper.",
                                "Combine all and serve immediately.",
                              ],
                              nutrition: const {
                                "Calories": "480 kcal",
                                "Protein": "18g",
                                "Fat": "20g",
                                "Carbs": "55g"
                              },
                              time: "20 mins",
                              cardWidth: screenWidth * 0.45,
                              cardHeight: screenHeight * 0.22,
                            ),
                            const SizedBox(width: 15),
                            _recipeCard(
                              context,
                              title: "Avocado Toast",
                              author: "By Jamie Lynn",
                              rating: "4.8",
                              imageUrl:
                                  "https://upload.wikimedia.org/wikipedia/commons/4/4d/Avocado_toast_with_egg.jpg",
                              ingredients: const [
                                "Bread",
                                "Avocado",
                                "Salt",
                                "Lemon Juice",
                                "Egg",
                                "Olive Oil"
                              ],
                              steps: const [
                                "Toast the bread to your liking.",
                                "Mash ripe avocado with salt and lemon.",
                                "Spread on toast, top with egg or chili flakes.",
                                "Drizzle olive oil and enjoy.",
                              ],
                              nutrition: const {
                                "Calories": "300 kcal",
                                "Protein": "10g",
                                "Fat": "16g",
                                "Carbs": "30g"
                              },
                              time: "10 mins",
                              cardWidth: screenWidth * 0.45,
                              cardHeight: screenHeight * 0.22,
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
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }

  Drawer _buildSideMenu(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFE95322),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=8'),
                  ),
                  SizedBox(width: 15),
                  Text(
                    "<Name>",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: 'League Spartan',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _menuItem(context, Icons.home, "Home", const HomePage()),
              _menuItem(context, Icons.fastfood, "Pantry", const PantryPage()),
              _menuItem(context, Icons.favorite, "Recipes", const RecipesPage()),
              _menuItem(context, Icons.list_alt, "Grocery List", null),
              _menuItem(context, Icons.person, "Profile", const ProfilePage()),
              _menuItem(context, Icons.settings, "Settings", const SettingsPage()),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _menuItem(BuildContext context, IconData icon, String title, Widget? page) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 26),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'League Spartan',
          fontSize: 17,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (page != null) {
          Navigator.pushReplacement(context, createRoute(page, fromRight: true));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title page coming soon!')),
          );
        }
      },
    );
  }
  // Recipe Card
  static Widget _recipeCard(
    BuildContext context, {
    required String title,
    required String author,
    required String rating,
    required String imageUrl,
    required List<String> ingredients,
    required List<String> steps,
    required Map<String, String> nutrition,
    required String time,
    required double cardWidth,
    required double cardHeight,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeOverviewScreen(
            title: title,
            imageUrl: imageUrl,
            details: "$rating★ · Quick Meal",
            description:
                "A quick, simple, and delicious dish to make anytime!",
            ingredients: ingredients,
            steps: steps,
            nutrition: nutrition,
            time: time,
          ),
        ),
      ),
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                imageUrl,
                height: cardHeight * 0.5,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: cardHeight * 0.5,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey, size: 30),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'League Spartan',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'League Spartan',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF391713),
                          fontFamily: 'League Spartan',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Grocery List Card
  static Widget _mealCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.network(
              imageUrl,
              height: height * 0.5,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: height * 0.5,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 30),
                );
              },
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'League Spartan',
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'League Spartan',
            ),
          ),
        ],
      ),
    );
  }

  // Calorie Card
  static Widget _calorieCard(BuildContext context, double width, double height) {
    return GestureDetector(
      onTap: () => Navigator.push(context, createRoute(const ProfilePage(), fromRight: true)),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: height * 0.55,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE6DC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${CalorieData.current} / ${CalorieData.goal} kcal",
                        style: const TextStyle(
                          fontFamily: 'League Spartan',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF391713),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: CalorieData.progress,
                          backgroundColor: Colors.white,
                          color: const Color(0xFFE95322),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Calorie Stats",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'League Spartan',
              ),
            ),
            const Text(
              "Tap for details",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'League Spartan',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
