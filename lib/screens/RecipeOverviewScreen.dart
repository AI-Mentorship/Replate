import 'package:flutter/material.dart';
import 'CookingAssistantScreen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeOverviewScreen extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String details;
  final String description;
  final List<String> steps;
  final List<String> ingredients;
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
  final TextEditingController _subInputController = TextEditingController();
  String? chatbotReply;

  Future<void> sendToChatbot(String question) async {
    try {
      final response = await http.post(
        Uri.parse("https://your-backend-url.com/chatbot/substitution"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": question}),
      );
      final reply = jsonDecode(response.body)["reply"];
      setState(() => chatbotReply = reply);
    } catch (e) {
      setState(() => chatbotReply =
          "Sorry, couldn’t connect to the chatbot right now.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0B03A),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 64,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Recipe Overview",
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

            // main content
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
                          errorBuilder: (context, error, stack) =>
                              Container(height: 220, color: Colors.grey[300]),
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
                      Text(
                        "${widget.time} • ${widget.details}",
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
                      ...widget.ingredients.map(
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
                          onPressed: () {
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
                                ingredients: widget.ingredients,
                                subInputController: _subInputController,
                                chatbotReply: chatbotReply,
                                onSubmit: (query) async {
                                  await sendToChatbot(query);
                                },
                              ),
                            );
                          },
                          child: const Text(
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
                                (entry) => Text(
                                  "${entry.key}: ${entry.value}",
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
                          steps: widget.steps,
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

class _SubstitutionSheet extends StatefulWidget {
  final List<String> ingredients;
  final TextEditingController subInputController;
  final String? chatbotReply;
  final Future<void> Function(String) onSubmit;

  const _SubstitutionSheet({
    required this.ingredients,
    required this.subInputController,
    required this.chatbotReply,
    required this.onSubmit,
  });

  @override
  State<_SubstitutionSheet> createState() => _SubstitutionSheetState();
}

class _SubstitutionSheetState extends State<_SubstitutionSheet> {
  final mockSubs = {
    'oil': ['Butter', 'Avocado oil'],
    'chicken': ['Tofu', 'Paneer', 'Mushrooms'],
    'milk': ['Oat milk', 'Almond milk', 'Coconut milk'],
    'onions': ['Shallots', 'Leeks'],
  };

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

            // Auto Suggestions
            ...widget.ingredients.map((item) {
              final subs = mockSubs.entries
                  .where((e) => item.toLowerCase().contains(e.key))
                  .map((e) => e.value)
                  .expand((e) => e)
                  .toList();

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
                    if (subs.isNotEmpty)
                      ...subs.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(left: 15, top: 3),
                          child: Text(
                            "→ $s",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

            const Divider(thickness: 1, height: 30),

            // Custom question input
            const Center(
              child: Text(
                "Ask your own substitution question:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF391713),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: widget.subInputController,
                decoration: InputDecoration(
                  hintText: "e.g. Can I use oat milk instead of regular milk?",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final query = widget.subInputController.text.trim();
                  if (query.isEmpty) return;
                  await widget.onSubmit(query);
                  FocusScope.of(context).unfocus();
                  widget.subInputController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE95322),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                ),
                child: const Text(
                  "Submit Question",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'League Spartan',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (widget.chatbotReply != null) ...[
              const SizedBox(height: 20),
              const Text(
                "Chatbot Reply:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF391713),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.chatbotReply!,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
