import 'package:flutter/material.dart';
import 'FullRecipeScreen.dart';
import '../widgets/VoicePoweredAssistant.dart';

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

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.steps.length - 1);
  }

  void _next() {
    if (_index < widget.steps.length - 1) {
      setState(() => _index++);
    }
  }

  void _back() {
    if (_index > 0) {
      setState(() => _index--);
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
  }

 void _help() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VoicePoweredAssistant(),
    );
  }
  void _camera() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera will open here (coming soon)'),
        behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    final total = widget.steps.length;
    final stepText = widget.steps[_index];

    return Scaffold(
      backgroundColor: const Color(0xFFE0B03A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SizedBox(
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'Step ${_index + 1} of $total',
                      style: const TextStyle(
                        color: Color(0xFF1D1D1D),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'League Spartan',
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFFE95322),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _roundAction(
                    icon: Icons.chat_bubble_outline,
                    label: 'Help',
                    onTap: _help,
                  ),
                  _roundAction(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: _camera,
                  ),
                  _roundAction(
                    icon: Icons.assignment_outlined,
                    label: 'Full Recipe',
                    onTap: _fullRecipe,
                  ),
                ],
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 22),
              child: Row(
                children: [
                  Expanded(
                    child: _pillButton(
                      label: 'Back',
                      onPressed: _index > 0 ? _back : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _pillButton(
                      label: 'Repeat',
                      filled: true,
                      onPressed: _repeat,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _pillButton(
                      label: 'Next',
                      onPressed: _index < total - 1 ? _next : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _roundAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
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
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
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
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: filled ? 2 : 0,
          backgroundColor: onPressed == null ? bg.withOpacity(0.5) : bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
