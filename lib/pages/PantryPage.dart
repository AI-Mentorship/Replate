import 'package:flutter/material.dart';
import '../pages/HomePage.dart';
import '../widgets/BottomNavBar.dart';
import '../screens/GroceryListScreen.dart';
import 'package:replate/utils/CameraHelper.dart';

class PantryPage extends StatelessWidget {
  const PantryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0B03A),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            SizedBox(
              width: double.infinity,
              height: 64,
              child: Center(
                child: Text(
                  'Pantry',
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

            // White content area
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),

                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 25,
                  ),
                  child: Column(
                    children: [
                      // Search bar and buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search',
                                  hintStyle: TextStyle(
                                    fontFamily: 'League Spartan',
                                    color: Colors.grey,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Camera (+) button
                          GestureDetector(
                            onTap: () async {
                              final image =
                                  await CameraHelper.pickImageFromCamera();

                              if (image != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ingredient photo captured!'),
                                  ),
                                );
                                print('Captured image: ${image.path}');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No image captured'),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE95322),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Cart button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GroceryListScreen(),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Color(0xFFE95322),
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Food Grid
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                          children: const [
                            _FoodItem(
                              name: 'Carrots',
                              imageUrl:
                                  'https://images.unsplash.com/photo-1582515073490-dc89d7d1e357?auto=format&fit=crop&w=400&q=80',
                            ),
                            _FoodItem(
                              name: 'Ground Beef',
                              imageUrl:
                                  'https://images.unsplash.com/photo-1601050690597-02fae3f165a5?auto=format&fit=crop&w=400&q=80',
                            ),
                            _FoodItem(
                              name: 'Eggs',
                              imageUrl:
                                  'https://images.unsplash.com/photo-1606755962773-0b1a3a3a9780?auto=format&fit=crop&w=400&q=80',
                            ),
                            _FoodItem(
                              name: 'Chicken Breast',
                              imageUrl:
                                  'https://images.unsplash.com/photo-1604908177522-060ff1b72db2?auto=format&fit=crop&w=400&q=80',
                            ),
                            _FoodItem(
                              name: 'Tomatoes',
                              imageUrl:
                                  'https://images.unsplash.com/photo-1570819177851-02fbe9b2f251?auto=format&fit=crop&w=400&q=80',
                            ),
                            _FoodItem(
                              name: 'Milk',
                              imageUrl:
                                  'https://images.unsplash.com/photo-1585238342028-1eafde4b1f9c?auto=format&fit=crop&w=400&q=80',
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

      // Bottom nav bar
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
    );
  }
}

// Food item widget
class _FoodItem extends StatelessWidget {
  final String name;
  final String imageUrl;

  const _FoodItem({required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                width: double.infinity,
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 30,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFE95322),
            fontFamily: 'League Spartan',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
