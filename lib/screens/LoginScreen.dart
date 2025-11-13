import 'package:flutter/material.dart';
import '../pages/HomePage.dart';
import 'SignUpScreen.dart';
import '../data/SupabaseRepo.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _repo = SupabaseRepo();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0B03A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            SizedBox(
              width: double.infinity,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: Text(
                      'Log In',
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
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFFE95322)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 35),
                  child: SingleChildScrollView(
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Welcome',
                              style: TextStyle(
                                  color: Color(0xFF391713),
                                  fontSize: 24,
                                  fontFamily: 'League Spartan')),
                          const SizedBox(height: 30),
                          _buildLabel('Email'),
                          _buildTextField(_emailCtrl, 'example@example.com', keyboardType: TextInputType.emailAddress, autofillHint: AutofillHints.email),
                          const SizedBox(height: 20),
                          _buildLabel('Password'),
                          _buildTextField(_passCtrl, '************', isPassword: true, keyboardType: TextInputType.visiblePassword, autofillHint: AutofillHints.password),
                          const SizedBox(height: 30),
                          _buildLoginButton(context),
                          const SizedBox(height: 15),
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignUpScreen()),
                              ),
                              child: const Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: "Don’t have an account? ",
                                    style: TextStyle(
                                        color: Color(0xFF391713),
                                        fontSize: 14,
                                        fontFamily: 'League Spartan')),
                                TextSpan(
                                    text: "Sign Up",
                                    style: TextStyle(
                                        color: Color(0xFFE95322),
                                        fontSize: 14,
                                        fontFamily: 'League Spartan')),
                              ])),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(
          color: Color(0xFF391713), fontSize: 18, fontFamily: 'League Spartan'));

  Widget _buildTextField(TextEditingController ctrl, String hint,
      {bool isPassword = false,
      TextInputType keyboardType = TextInputType.text,
      String? autofillHint}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      keyboardType: keyboardType,
      autocorrect: false,
      enableSuggestions: false,
      textCapitalization: TextCapitalization.none,
      autofillHints: autofillHint != null ? [autofillHint] : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF3E9B5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: _loading
              ? null
              : () async {
                  setState(() => _loading = true);
                  try {
                    final response =
                        await _repo.signIn(_emailCtrl.text.trim(), _passCtrl.text.trim());
                    if (response.user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid login credentials')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Login failed: $e')));
                  } finally {
                    setState(() => _loading = false);
                  }
                },
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
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
