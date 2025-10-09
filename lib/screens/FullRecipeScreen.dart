import 'package:flutter/material.dart';
import 'CookingAssistantScreen.dart';

class FullRecipeScreen extends StatelessWidget {
  final String recipeTitle;
  final List<String> steps;

  const FullRecipeScreen({
    super.key,
    required this.recipeTitle,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0B03A),
      body: SafeArea(
        child: Column(
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Text(
                    'Full Recipe',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'League Spartan',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(width: 24), // keeps title centered
                ],
              ),
            ),

            // White background content
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE6A0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: ListView.builder(
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Color(0xFF391713),
                              fontFamily: 'League Spartan',
                              fontSize: 16,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: 'Step ${index + 1}: ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: steps[index]),
                            ],
                          ),
                        ),
                      );
                    },
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
