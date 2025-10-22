import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/CameraHelper.dart';

class ChatbotScreen extends StatefulWidget {
  final String recipeTitle;
  final String currentStep;

  const ChatbotScreen({
    super.key,
    required this.recipeTitle,
    required this.currentStep,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
    });
    _controller.clear();

    // HARDCODED AI response (replace with backend call)
    Future.delayed(const Duration(milliseconds: 600), () {
      final response =
          "Try simmering it for 5 more minutes or add 1 tsp cornstarch mixed with water.";
      setState(() {
        _messages.add({'sender': 'bot', 'text': response});
      });
      _tts.speak(response); // speak AI to reply out loud
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          if (val.finalResult) {
            _sendMessage(val.recognizedWords);
            setState(() => _isListening = false);
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _camera() async {
    final image = await CameraHelper.pickImageFromCamera();
    if (image != null) {
      setState(() {
        _messages.add({'sender': 'user', 'text': '[📸 Sent image to analyze]'});
      });
      // TODO: send image to backend for visual analysis
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0B03A),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0B03A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "AI Cooking Assistant",
          style: TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w700,
              color: Color(0xFF391713)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFFE95322)
                          : const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser
                            ? Colors.white
                            : const Color(0xFF391713),
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.mic,
                      color: _isListening
                          ? const Color(0xFFE95322)
                          : const Color(0xFF391713)),
                  onPressed: _listen,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask me something...",
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFE95322)),
                  onPressed: () => _sendMessage(_controller.text),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.camera_alt, color: Color(0xFF391713)),
                  onPressed: _camera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
