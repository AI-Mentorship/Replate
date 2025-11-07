import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/BottomNavBar.dart';
import '../screens/GroceryListScreen.dart';
// import '../utils/CameraHelper.dart'; // Uncomment when testing on phone

class PantryPage extends StatefulWidget {
  const PantryPage({super.key});

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  final supabase = Supabase.instance.client;
  bool _editMode = false;
  bool _loading = true;
  List<Map<String, dynamic>> _pantryItems = [];

  @override
  void initState() {
    super.initState();
    _initializePantry();
  }

  Future<void> _initializePantry() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final user = supabase.auth.currentUser;

    if (user == null) {
      supabase.auth.onAuthStateChange.listen((event) async {
        if (event.session?.user != null) {
          await _loadPantry();
        }
      });
    } else {
      await _loadPantry();
    }
  }

  Future<void> _loadPantry() async {
    setState(() => _loading = true);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await supabase
          .from('pantry')
          .select()
          .eq('user_id', userId)
          .order('added', ascending: false);

      if (mounted) {
        setState(() {
          _pantryItems = List<Map<String, dynamic>>.from(response);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Pantry load error: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addItemDialog() async {
    final userId = supabase.auth.currentUser?.id ?? '';
    final newItem = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _AddItemDialog(),
    );

    if (newItem != null && newItem['name'].isNotEmpty) {
      await supabase.from('pantry').insert({
        'user_id': userId,
        'item_name': newItem['name'],
        'quantity': newItem['qty'],
        'added': newItem['added'],
        'expires': newItem['expires'],
      });
      await _loadPantry(); 
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    if (!mounted) return;
    final itemName = item['item_name'] ?? 'Item';
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

    if (shouldDelete != true) return;

    try {
      await supabase.from('pantry').delete().eq('item_id', item['item_id']);
      await _loadPantry();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$itemName removed"),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint("Delete error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error removing item.")),
      );
    }
  }

  Future<void> _openCamera() async {
    final isSimulator = !Platform.isAndroid && !Platform.isIOS;
    if (isSimulator) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Camera not available on simulator."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Uncomment when testing on phone:
    // final image = await CameraHelper.pickImageFromCamera();
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text(image != null ? "Photo captured!" : "No photo taken.")),
    // );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Camera feature works on real devices."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatItemName(String? name, String? qty) {
    if (name == null || name.isEmpty) return '';
    if (qty == null || qty == '1') return name;
    return "$name (x$qty)";
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
                    top: 12,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.camera_alt_outlined,
                              color: Colors.white, size: 24),
                          onPressed: _openCamera,
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => setState(() => _editMode = !_editMode),
                          child: Text(
                            _editMode ? 'Done' : 'Edit',
                            style: TextStyle(
                              color: _editMode
                                  ? const Color(0xFFE95322)
                                  : Colors.white,
                              fontSize: 16,
                              fontFamily: 'League Spartan',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
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
                              child:
                                  const Icon(Icons.add, color: Colors.white),
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

                      // Main Grid
                      Expanded(
                        child: _loading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFE95322),
                                ),
                              )
                            : _pantryItems.isEmpty
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
                                        List.generate(_pantryItems.length, (i) {
                                      final item = _pantryItems[i];
                                      final name = _formatItemName(
                                          item['item_name'], item['quantity']);
                                      final added = item['added'] ?? '';
                                      final expires = item['expires'] ?? '';
                                      final isRed = _isNearExpiry(expires);

                                      return Stack(
                                        children: [
                                          _FoodItem(
                                            name: name,
                                            added: added,
                                            expires: expires,
                                            highlight: isRed,
                                          ),
                                          if (_editMode)
                                            Positioned(
                                              top: 6,
                                              right: 6,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    _confirmDelete(item),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(3),
                                                  decoration:
                                                      const BoxDecoration(
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

// Food Item Card
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 4),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              "Added: ${added.isEmpty ? '—' : added}",
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
    );
  }
}

// Add Item Dialog
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
      title:
          const Text("Add Pantry Item", style: TextStyle(fontFamily: 'League Spartan')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Item name")),
          TextField(controller: _qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Quantity")),
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
              _expires == null ? "Set Expiration Date" : "Expires: $_expires",
              style: const TextStyle(color: Color(0xFFE95322)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE95322)),
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
