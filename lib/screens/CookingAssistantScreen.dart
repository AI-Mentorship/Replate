import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/CameraHelper.dart';
import 'FullRecipeScreen.dart';
import 'ChatbotScreen.dart';

class CookingAssistantScreen extends StatefulWidget {
  final String recipeTitle;
  final List<String> steps;
  final int initialIndex;

  const CookingAssistantScreen({
    super.key,
    required this.steps,
    this.recipeTitle = 'Recipe',
    this.initialIndex = 0,
  });

  @override
  State<CookingAssistantScreen> createState() => _CookingAssistantScreenState();
}

class _CookingAssistantScreenState extends State<CookingAssistantScreen> {
  late int _index;
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.steps.length - 1);
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _speakCurrentStep();
  }

  Future<void> _speakCurrentStep() async {
    await _tts.stop();
    await _tts.speak(widget.steps[_index]);
  }

  void _next() {
    if (_index < widget.steps.length - 1) {
      setState(() => _index++);
      _speakCurrentStep();
    }
  }

  void _back() {
    if (_index > 0) {
      setState(() => _index--);
      _speakCurrentStep();
    }
  }

  void _repeat() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Repeating Step ${_index + 1}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 800),
      ),
    );
    _speakCurrentStep();
  }

  void _openChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatbotScreen(
          recipeTitle: widget.recipeTitle,
          currentStep: widget.steps[_index],
        ),
      ),
    );
  }

  Future<void> _camera() async {
    final image = await CameraHelper.pickImageFromCamera();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(image != null ? "Photo captured successfully!" : "No photo captured."),
      ),
    );
  }

  void _fullRecipe() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullRecipeScreen(
          recipeTitle: widget.recipeTitle,
          steps: widget.steps,
        ),
      ),
    );
  }

  void _listenVoice() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          if (val.finalResult) {
            final cmd = val.recognizedWords.toLowerCase();
            if (cmd.contains('next')) _next();
            else if (cmd.contains('back')) _back();
            else if (cmd.contains('repeat')) _repeat();
            else if (cmd.contains('help')) _openChatbot();
            else if (cmd.contains('full')) _fullRecipe();
            setState(() => _isListening = false);
            _speech.stop();
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.steps.length;
    final stepText = widget.steps[_index];

    return Scaffold(
      backgroundColor: const Color(0xFFE0B03A),
      body: SafeArea(
        child: Column(
          children: [
            // Header Row (Back Arrow, Step Text, Mic)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFE95322)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Step ${_index + 1} of $total',
                        style: const TextStyle(
                          color: Color(0xFF1D1D1D),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'League Spartan',
                        ),
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    backgroundColor: const Color(0xFFE95322),
                    mini: true,
                    onPressed: _listenVoice,
                    child: Icon(
                      _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Step Text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final base = (constraints.maxWidth / 16).clamp(16.0, 26.0);
                      return Text(
                        '“$stepText”',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: base,
                          height: 1.35,
                          color: const Color(0xFF391713),
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final gap = 12.0;
                  final buttonWidth = (constraints.maxWidth - 2 * gap) / 3;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: buttonWidth,
                        child: _roundAction(
                          icon: Icons.chat_bubble_outline,
                          label: 'Help',
                          onTap: _openChatbot,
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: _roundAction(
                          icon: Icons.camera_alt_outlined,
                          label: 'Camera',
                          onTap: _camera,
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: _roundAction(
                          icon: Icons.assignment_outlined,
                          label: 'Full Recipe',
                          onTap: _fullRecipe,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 22),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final gap = 12.0;
                  final buttonWidth = (constraints.maxWidth - 2 * gap) / 3;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: buttonWidth,
                        child: _pillButton(
                          label: 'Back',
                          onPressed: _index > 0 ? _back : null,
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: _pillButton(
                          label: 'Repeat',
                          filled: true,
                          onPressed: _repeat,
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: _pillButton(
                          label: 'Next',
                          onPressed: _index < total - 1 ? _next : null,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI Helpers
  Widget _roundAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkResponse(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: Icon(icon, color: const Color(0xFFE95322)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF391713),
            fontFamily: 'League Spartan',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _pillButton({
    required String label,
    required VoidCallback? onPressed,
    bool filled = false,
  }) {
    final bg = filled ? const Color(0xFFE95322) : Colors.white;
    final fg = filled ? Colors.white : const Color(0xFF391713);
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: filled ? 2 : 0,
          backgroundColor: onPressed == null ? bg.withOpacity(0.5) : bg,
          foregroundColor: fg,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'League Spartan',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
