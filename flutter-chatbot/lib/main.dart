import 'package:flutter/material.dart';
import 'screens/chatbot_screen.dart';

void main() {
  runApp(const CookingChatbotApp());
}

class CookingChatbotApp extends StatelessWidget {
  const CookingChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatbotScreen(
        recipeTitle: "Welcome",
        currentStep: "Start by asking a question!",
      ),
    );
  }
}
