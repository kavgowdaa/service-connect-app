import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final ApiService api = ApiService();

  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;
    final confirmPassword = confirmController.text;

    // Validation
    if (name.isEmpty) {
      showMessage('Please enter your name');
      return;
    }

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      showMessage('Please enter a valid email address');
      return;
    }

    if (password.length < 6) {
      showMessage('Password must be at least 6 characters');
      return;
    }

    if (password != confirmPassword) {
      showMessage('Passwords do not match');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      debugPrint('==========================================');
      debugPrint('REGISTER');
      debugPrint('NAME: $name');
      debugPrint('EMAIL: $email');
      debugPrint('==========================================');

      await api.register(name: name, email: email, password: password);

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login.'),
          backgroundColor: Color(0xFF1D9B61),
        ),
      );

      // Go back to Login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      final message = e.toString().replaceFirst('Exception: ', '');

      showMessage(message);
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071A33),

      appBar: AppBar(
        backgroundColor: const Color(0xFF071A33),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Create Account',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),

              child: Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: const Color(0xFF102846),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF294566)),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Create your account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Join ServiceConnect and find trusted professionals.',
                      style: TextStyle(color: Color(0xFF8296B5), fontSize: 12),
                    ),

                    const SizedBox(height: 25),

                    // NAME
                    const Text(
                      'Full Name',
                      style: TextStyle(
                        color: Color(0xFFD8E2F1),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    _buildTextField(
                      controller: nameController,
                      hint: 'Enter your full name',
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 17),

                    // EMAIL
                    const Text(
                      'Email',
                      style: TextStyle(
                        color: Color(0xFFD8E2F1),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    _buildTextField(
                      controller: emailController,
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 17),

                    // PASSWORD
                    const Text(
                      'Password',
                      style: TextStyle(
                        color: Color(0xFFD8E2F1),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    _buildTextField(
                      controller: passwordController,
                      hint: 'Create a password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF7189AA),
                        ),
                      ),
                    ),

                    const SizedBox(height: 17),

                    // CONFIRM PASSWORD
                    const Text(
                      'Confirm Password',
                      style: TextStyle(
                        color: Color(0xFFD8E2F1),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    _buildTextField(
                      controller: confirmController,
                      hint: 'Confirm your password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: obscureConfirmPassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF7189AA),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // REGISTER BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton(
                        onPressed: loading ? null : register,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF216BFF),
                          disabledBackgroundColor: const Color(
                            0xFF216BFF,
                          ).withValues(alpha: 0.5),
                          foregroundColor: Colors.white,
                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),

                        child: loading
                            ? const SizedBox(
                                height: 21,
                                width: 21,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.3,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // LOGIN
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },

                        child: const Text.rich(
                          TextSpan(
                            text: 'Already have an account? ',

                            style: TextStyle(
                              color: Color(0xFF8296B5),
                              fontSize: 12,
                            ),

                            children: [
                              TextSpan(
                                text: 'Login',

                                style: TextStyle(
                                  color: Color(0xFF4B8BFF),
                                  fontWeight: FontWeight.w700,
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
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,

      style: const TextStyle(color: Colors.white, fontSize: 13),

      cursorColor: const Color(0xFF4B8BFF),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: const TextStyle(color: Color(0xFF7186A5), fontSize: 12),

        prefixIcon: Icon(icon, color: const Color(0xFF7189AA), size: 19),

        suffixIcon: suffixIcon,

        filled: true,

        fillColor: const Color(0xFF0B203A),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFF294566)),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFF294566)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFF3478F6), width: 1.3),
        ),
      ),
    );
  }
}
