import 'package:flutter/material.dart';
import 'LogInScreen.dart';
import 'SignUpScreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE95322),
      body: SafeArea(
        child: Stack(
          children: [
            // REPLATE title
            const Align(
              alignment: Alignment(0, -0.1),
              child: Text(
                'REPLATE',
                style: TextStyle(
                  color: Color(0xFFF5CB58),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),

            // Subtitle
            const Align(
              alignment: Alignment(0, 0.15),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Your AI kitchen assistant for smarter cooking, less waste, and healthier eating.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFF8F8F8),
                    fontSize: 14,
                    fontFamily: 'League Spartan',
                    height: 1.4,
                  ),
                ),
              ),
            ),

            // Buttons
            Align(
              alignment: const Alignment(0, 0.55),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildButton(
                    text: 'Log In',
                    bgColor: const Color(0xFFF5CB58),
                    textColor: const Color(0xFFE95322),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LogInScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildButton(
                    text: 'Sign Up',
                    bgColor: const Color(0xFFF3E9B5),
                    textColor: const Color(0xFFE95322),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildButton({
    required String text,
    required Color bgColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 210,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontFamily: 'League Spartan',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
