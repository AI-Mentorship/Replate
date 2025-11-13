import 'package:flutter/material.dart';
import '../data/SupabaseRepo.dart';
import '../pages/HomePage.dart';
import 'LogInScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _repo = SupabaseRepo();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
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
                      'Sign Up',
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
                          _buildLabel('Full Name'),
                          _buildTextField(_nameCtrl, 'John Doe', keyboardType: TextInputType.name),
                          const SizedBox(height: 20),
                          _buildLabel('Email'),
                          _buildTextField(
                            _emailCtrl,
                            'example@example.com',
                            keyboardType: TextInputType.emailAddress,
                            autofillHint: AutofillHints.email,
                          ),
                          const SizedBox(height: 20),
                          _buildLabel('Password'),
                          _buildTextField(
                            _passCtrl,
                            '********',
                            isPassword: true,
                            keyboardType: TextInputType.visiblePassword,
                            autofillHint: AutofillHints.password,
                          ),
                          const SizedBox(height: 30),
                          _buildSignUpButton(context),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LogInScreen()),
                            ),
                            child: const Center(
                              child: Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: "Already have an account? ",
                                    style: TextStyle(
                                        color: Color(0xFF391713),
                                        fontSize: 12,
                                        fontFamily: 'League Spartan')),
                                TextSpan(
                                    text: "Log In",
                                    style: TextStyle(
                                        color: Color(0xFFE95322),
                                        fontSize: 12,
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

  Widget _buildSignUpButton(BuildContext context) {
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
                    final email = _emailCtrl.text.trim();
                    final pass = _passCtrl.text.trim();
                    final name = _nameCtrl.text.trim();

                    if (email.isEmpty || pass.isEmpty || name.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                      setState(() => _loading = false);
                      return;
                    }

                    // sign up
                    final response = await _repo.signUp(email, pass, name);

                    if (response.user != null) {
                      // success - go to home
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    } else {
                      // If using email confirmations, supabase may return a session==null until confirmed.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sign up incomplete: ${response.session == null ? "confirm email if required" : "unknown"}')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error: $e')));
                  } finally {
                    setState(() => _loading = false);
                  }
                },
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Sign Up',
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
