import 'package:flutter/material.dart';
import 'CookingAssistantScreen.dart';
import '../data/SupabaseRepo.dart';

class RecipeOverviewScreen extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String details;
  final String description;
  final List<dynamic> steps;
  final List<dynamic> ingredients;
  final Map<String, String> nutrition;
  final String time;

  const RecipeOverviewScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.details,
    required this.description,
    required this.steps,
    required this.ingredients,
    required this.nutrition,
    required this.time,
  });

  @override
  State<RecipeOverviewScreen> createState() => _RecipeOverviewScreenState();
}

class _RecipeOverviewScreenState extends State<RecipeOverviewScreen> {
  final repo = SupabaseRepo();

  bool _loadingSubs = true;
  List<Map<String, dynamic>> _subs = [];

  @override
  void initState() {
    super.initState();
    _loadSubstitutions();
  }

  Future<void> _loadSubstitutions() async {
    try {
      final rows = await repo.fetchSubstitutions();
      setState(() {
        _subs = rows.cast<Map<String, dynamic>>();
        _loadingSubs = false;
      });
    } catch (e) {
      debugPrint('Error loading substitutions: $e');
      setState(() => _loadingSubs = false);
    }
  }

  List<String> _formatIngredients(List<dynamic> ingredients) {
    if (ingredients.isEmpty) return ["No ingredients listed."];
    final joined = ingredients.join(',');
    return joined
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final formattedIngredients = _formatIngredients(widget.ingredients);
    final formattedSteps = _formatIngredients(widget.steps);

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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Recipe Overview',
                      style: TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.imageUrl,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, __) => Container(
                            height: 220,
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 42,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF391713),
                          fontFamily: 'League Spartan',
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (widget.time.isNotEmpty || widget.details.isNotEmpty)
                        Text(
                          [
                            if (widget.time.isNotEmpty) widget.time,
                            if (widget.details.isNotEmpty) widget.details,
                          ].join("  "), 
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: 'League Spartan',
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        widget.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF391713),
                          fontFamily: 'League Spartan',
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        "Ingredients",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF391713),
                          fontFamily: 'League Spartan',
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...formattedIngredients.map(
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(
                            "• $i",
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'League Spartan',
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE95322),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _loadingSubs
                              ? null
                              : () {
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(25),
                                      ),
                                    ),
                                    builder: (_) => _SubstitutionSheet(
                                      ingredients: formattedIngredients,
                                      substitutions: _subs,
                                    ),
                                  );
                                },
                          child: _loadingSubs
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Find Substitutions",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'League Spartan',
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Nutrition Facts",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'League Spartan',
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...widget.nutrition.entries.map(
                                (e) => Text(
                                  "${e.key}: ${e.value}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'League Spartan',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),

            // Start Cooking button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE95322),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CookingAssistantScreen(
                          recipeTitle: widget.title,
                          steps: formattedSteps,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Start Cooking",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: 'League Spartan',
                    ),
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

/// Bottom sheet: substitution suggestions
class _SubstitutionSheet extends StatelessWidget {
  final List<String> ingredients;
  final List<Map<String, dynamic>> substitutions;

  const _SubstitutionSheet({
    required this.ingredients,
    required this.substitutions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Substitution Suggestions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF391713),
              ),
            ),
            const SizedBox(height: 15),

            ...ingredients.map((item) {
              final matches = substitutions.where((s) {
                final ing = (s['ingredient'] ?? '').toString().toLowerCase();
                return ing.isNotEmpty && item.toLowerCase().contains(ing);
              }).toList();

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "• $item",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (matches.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 15, top: 3),
                        child: Text(
                          "→ No live substitutions found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ...matches.map((m) {
                      final alt = (m['alt_name'] ?? '').toString();
                      final delta =
                          (m['nutrition_delta'] ?? 'similar nutrition')
                              .toString();
                      return Padding(
                        padding: const EdgeInsets.only(left: 15, top: 3),
                        child: Text(
                          "→ $alt ($delta)",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),

            if (ingredients.isEmpty)
              const Center(
                child: Text(
                  "No ingredients listed.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'League Spartan',
                  ),
                ),
              ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
