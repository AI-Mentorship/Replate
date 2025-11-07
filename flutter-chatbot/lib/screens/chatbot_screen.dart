import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _showCookingBar = false;
  bool _voiceEnabled = true;

  // Store last spoken response for replay
  String? _lastBotResponse;

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  Future<String> _sendToBackend(String text) async {
    final uri = Uri.parse("http://127.0.0.1:8000/chat");

    var request = http.MultipartRequest("POST", uri);
    request.fields['message'] = text;

    final response = await request.send();
    final resBody = await response.stream.bytesToString();
    final data = json.decode(resBody);

    return data["response"] ?? "Error: No response";
  }

  void _sendCommand(String cmd) {
    _sendMessage(cmd);
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() => _messages.add({'sender': 'user', 'text': text}));
    _controller.clear();

    setState(() => _messages.add({'sender': 'bot', 'text': 'Thinking...'}));

    final reply = await _sendToBackend(text);

    setState(() {
      _messages.removeLast();
      _messages.add({'sender': 'bot', 'text': reply});
    });

    // Store for replay
    _lastBotResponse = reply;

    // Auto-show cooking controls if recipe detected
    if (reply.contains("DIRECTIONS") ||
        reply.toLowerCase().contains("step 1")) {
      setState(() => _showCookingBar = true);
    }

    // Auto-hide when cooking ends
    if (reply.toLowerCase().contains("hands-free cooking mode stopped") ||
        reply.toLowerCase().contains("stopped hands-free cooking mode")) {
      setState(() => _showCookingBar = false);
    }

    await Future.delayed(const Duration(milliseconds: 50));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    // Stop any currently speaking audio before speaking new stuff
    await _tts.stop();

    if (_voiceEnabled && _lastBotResponse != null) {
      await _tts.speak(_lastBotResponse!);
    }
  }

  // UPDATED FUNCTION
  void _listen() async {
    try {
      // Prevent crash on iOS Simulator (no real mic support)
      if (Platform.isIOS) {
        const simulator =
            String.fromEnvironment('SIMULATOR_DEVICE_NAME', defaultValue: '');
        if (simulator.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Voice input is not supported on the iOS simulator. Please run this on a real device.",
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
      }

      if (!_isListening) {
        bool available = await _speech.initialize(
          onError: (val) => debugPrint("Speech error: $val"),
          onStatus: (val) => debugPrint("Speech status: $val"),
        );

        if (!available) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Microphone not available or permission denied."),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) async {
            if (val.finalResult && val.recognizedWords.isNotEmpty) {
              await _sendMessage(val.recognizedWords);
              await _speech.stop();
              setState(() => _isListening = false);
            }
          },
        );
      } else {
        await _speech.stop();
        setState(() => _isListening = false);
      }
    } catch (e) {
      debugPrint("Speech listen error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Speech error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
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
            color: Color(0xFF391713),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFE95322) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : const Color(0xFF391713),
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_showCookingBar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _sendCommand("start cooking"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE95322),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: const Text("Start",
                        style: TextStyle(color: Colors.white)),
                  ),
                  IconButton(
                    onPressed: () => _sendCommand("back"),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF391713)),
                    tooltip: "Back",
                  ),
                  IconButton(
                    onPressed: () => _sendCommand("repeat"),
                    icon: const Icon(Icons.replay, color: Color(0xFF391713)),
                    tooltip: "Repeat",
                  ),
                  IconButton(
                    onPressed: () => _sendCommand("next"),
                    icon: const Icon(Icons.arrow_forward_ios,
                        color: Color(0xFF391713)),
                    tooltip: "Next",
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _sendCommand("stop"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE95322),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    icon: const Icon(Icons.stop, color: Colors.white),
                    label: const Text("Stop",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.mic,
                    color: _isListening
                        ? const Color(0xFFE95322)
                        : const Color(0xFF391713),
                  ),
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
                  icon: Icon(
                    _voiceEnabled ? Icons.volume_up : Icons.volume_off,
                    color: const Color(0xFF391713),
                  ),
                  onPressed: () async {
                    setState(() {
                      _voiceEnabled = !_voiceEnabled;
                    });

                    if (!_voiceEnabled) {
                      await _tts.stop();
                    } else {
                      if (_lastBotResponse != null) {
                        await _tts.speak(_lastBotResponse!);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
