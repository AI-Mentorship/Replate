import 'package:flutter/material.dart';

class VoicePoweredAssistant extends StatelessWidget {
  const VoicePoweredAssistant({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Text(
            "Ask the Cooking Assistant",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "You can ask for substitutions or clarification on this step.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.mic, size: 36, color: Colors.deepOrange),
            onPressed: () {
              // TODO: connect mic input or voice logic
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
