import 'package:flutter/material.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final TextEditingController _controller = TextEditingController();

  // Sample starting grocery data
  List<Map<String, dynamic>> groceryItems = [
    {"name": "Milk", "inPantry": true, "checked": false},
    {"name": "Tomatoes", "inPantry": true, "checked": false},
    {"name": "Olive Oil", "inPantry": false, "checked": false},
    {"name": "Garlic", "inPantry": false, "checked": false},
    {"name": "Spaghetti", "inPantry": false, "checked": false},
  ];

  // Simulate generating list from pantry + recipe data
  void _generateFromPantry() {
    setState(() {
      groceryItems.addAll([
        {"name": "Parmesan Cheese", "inPantry": false, "checked": false},
        {"name": "Basil", "inPantry": false, "checked": false},
      ]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Generated grocery list from pantry & recipes."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Add item manually
  void _addItem(String name) {
    if (name.trim().isEmpty) return;
    setState(() {
      groceryItems.add({
        "name": name.trim(),
        "inPantry": false,
        "checked": false,
      });
    });
    _controller.clear();
  }

  // Remove all checked (purchased) items
  void _clearChecked() {
    setState(() {
      groceryItems.removeWhere((item) => item["checked"] == true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0B03A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Grocery List',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'League Spartan',
                    ),
                  ),
                ],
              ),
            ),

            // Main container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Generate button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.sync, color: Colors.white),
                          label: const Text(
                            'Generate from Pantry',
                            style: TextStyle(
                              fontFamily: 'League Spartan',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: _generateFromPantry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE95322),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Grocery List Display
                      Expanded(
                        child: groceryItems.isEmpty
                            ? const Center(
                                child: Text(
                                  'Your grocery list is empty!',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'League Spartan',
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: groceryItems.length,
                                itemBuilder: (context, index) {
                                  final item = groceryItems[index];
                                  final name = item["name"];
                                  final inPantry = item["inPantry"];
                                  final checked = item["checked"];

                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: CheckboxListTile(
                                      activeColor: const Color(0xFFE95322),
                                      value: checked,
                                      onChanged: (val) => setState(
                                          () => item["checked"] = val ?? false),
                                      title: Text(
                                        name,
                                        style: TextStyle(
                                          fontFamily: 'League Spartan',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: checked
                                              ? Colors.grey
                                              : const Color(0xFF391713),
                                          decoration: checked
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      subtitle: Text(
                                        inPantry
                                            ? "Already in pantry"
                                            : "Needs to buy",
                                        style: TextStyle(
                                          fontFamily: 'League Spartan',
                                          color: inPantry
                                              ? Colors.green
                                              : Colors.redAccent,
                                          fontSize: 13,
                                        ),
                                      ),
                                      secondary: IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.grey),
                                        onPressed: () => setState(() =>
                                            groceryItems.removeAt(index)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Add Item Row
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: 'Add item manually...',
                                hintStyle: const TextStyle(
                                  fontFamily: 'League Spartan',
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _addItem(_controller.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE95322),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Clear Purchased Button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.check_circle_outline,
                              color: Color(0xFFE95322)),
                          label: const Text(
                            'Remove Purchased',
                            style: TextStyle(
                              color: Color(0xFFE95322),
                              fontFamily: 'League Spartan',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _clearChecked,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFFE95322), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
    );
  }
}
