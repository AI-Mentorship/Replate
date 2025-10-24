import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/BottomNavBar.dart';
import '../screens/GroceryListScreen.dart';
// import '../utils/CameraHelper.dart'; // uncomment when testing on phone

class PantryPage extends StatefulWidget {
  const PantryPage({super.key});

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  List<Map<String, dynamic>> pantryItems = [
    {'name': 'Carrots', 'added': '10/23/2025', 'expires': '', 'qty': '1'},
    {'name': 'Milk', 'added': '10/23/2025', 'expires': '', 'qty': '1'},
    {'name': 'Eggs', 'added': '10/23/2025', 'expires': '', 'qty': '5'},
  ];

  bool _editMode = false;

  // show quantity only if >1
  String _formatItemName(String? name, String? qty) {
    if (name == null || name.isEmpty) return '';
    if (qty == null || qty.isEmpty || qty == '1') return name;
    return "$name (x$qty)";
  }

  Future<void> _addItemDialog() async {
    final newItem = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AddItemDialog(),
    );

    if (newItem != null && newItem['name'] != null && newItem['name'] != '') {
      setState(() => pantryItems.add(newItem));
    }
  }

  Future<void> _confirmDelete(int index) async {
    final itemName = pantryItems[index]['name'];
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Remove Item",
          style: TextStyle(
            fontFamily: 'League Spartan',
            fontWeight: FontWeight.bold,
            color: Color(0xFFE95322),
          ),
        ),
        content: Text(
          "Are you sure you want to remove $itemName?",
          style: const TextStyle(fontFamily: 'League Spartan'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE95322),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Remove"),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() => pantryItems.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$itemName removed'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  bool _isNearExpiry(String date) {
    if (date.isEmpty) return false;
    try {
      final exp = DateFormat('MM/dd/yyyy').parse(date);
      return exp.difference(DateTime.now()).inDays <= 3;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0B03A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            SizedBox(
              width: double.infinity,
              height: 64,
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'Pantry',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'League Spartan',
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 18,
                    child: GestureDetector(
                      onTap: () => setState(() => _editMode = !_editMode),
                      child: Text(
                        _editMode ? 'Done' : 'Edit',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'League Spartan',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
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
                                  prefixIcon:
                                      Icon(Icons.search, color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _addItemDialog,
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

                      // Pantry grid
                      Expanded(
                        child: pantryItems.isEmpty
                            ? const Center(
                                child: Text(
                                  "No items yet - add some!",
                                  style: TextStyle(
                                    fontFamily: 'League Spartan',
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 10,
                                children:
                                    List.generate(pantryItems.length, (index) {
                                  final item = pantryItems[index];
                                  final expires = item['expires'] ?? '';
                                  final isRed = _isNearExpiry(expires);

                                  return Stack(
                                    children: [
                                      _FoodItem(
                                        name: _formatItemName(
                                            item['name'], item['qty']),
                                        added: item['added'] ?? '',
                                        expires: expires,
                                        highlight: isRed,
                                      ),
                                      if (_editMode)
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: GestureDetector(
                                            onTap: () =>
                                                _confirmDelete(index),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(3),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                }),
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
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
    );
  }
}

// Pantry item card
class _FoodItem extends StatelessWidget {
  final String name;
  final String added;
  final String expires;
  final bool highlight;

  const _FoodItem({
    required this.name,
    required this.added,
    required this.expires,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130, 
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: highlight ? Colors.red : const Color(0xFFE95322),
                  fontFamily: 'League Spartan',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "Added: $added",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontFamily: 'League Spartan',
                ),
              ),
              Text(
                "Expires: ${expires.isEmpty ? '—' : expires}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: highlight ? Colors.red : Colors.grey,
                  fontSize: 13,
                  fontFamily: 'League Spartan',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add Item dialog
class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog();

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: "1");
  String? _expires;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Add Pantry Item",
        style: TextStyle(fontFamily: 'League Spartan'),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: "Item name"),
          ),
          TextField(
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Quantity"),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() =>
                    _expires = DateFormat('MM/dd/yyyy').format(picked));
              }
            },
            child: Text(
              _expires == null
                  ? "Set Expiration Date"
                  : "Expires: $_expires",
              style: const TextStyle(color: Color(0xFFE95322)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE95322)),
          onPressed: () {
            final name = _nameCtrl.text.trim();
            if (name.isEmpty) return;
            Navigator.of(context).pop({
              'name': name,
              'qty': _qtyCtrl.text,
              'added': DateFormat('MM/dd/yyyy').format(DateTime.now()),
              'expires': _expires ?? '',
            });
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
