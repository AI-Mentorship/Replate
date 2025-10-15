import 'package:flutter/material.dart';
import 'SignUpScreen.dart';
import 'SetPasswordScreen.dart';
import '../pages/HomePage.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0B03A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            SizedBox(
              width: double.infinity,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: Text(
                      'Log In',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'League Spartan',
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFFE95322),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Form Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 35,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome',
                          style: TextStyle(
                            color: Color(0xFF391713),
                            fontSize: 24,
                            fontFamily: 'League Spartan',
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildLabel('Email or Mobile Number'),
                        _buildTextField('example@example.com'),
                        const SizedBox(height: 20),
                        _buildLabel('Password'),
                        _buildTextField('************', isPassword: true),
                        const SizedBox(height: 10),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SetPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFFE95322),
                                fontSize: 14,
                                fontFamily: 'League Spartan',
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        _buildLoginButton(context), 
                        const SizedBox(height: 15),

                        // Don’t have an account? Sign up
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Don’t have an account? ",
                                    style: TextStyle(
                                      color: Color(0xFF391713),
                                      fontSize: 14,
                                      fontFamily: 'League Spartan',
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Sign Up",
                                    style: TextStyle(
                                      color: Color(0xFFE95322),
                                      fontSize: 14,
                                      fontFamily: 'League Spartan',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF391713),
        fontSize: 18,
        fontFamily: 'League Spartan',
      ),
    );
  }

  Widget _buildTextField(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF391713),
          fontFamily: 'League Spartan',
          fontSize: 16,
        ),
        filled: true,
        fillColor: const Color(0xFFF3E9B5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 207,
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE95322),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
          child: const Text(
            'Log In',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
