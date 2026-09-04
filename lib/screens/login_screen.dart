import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'home_screen.dart';
import 'register_screen.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ============================================================
  // SERVICES
  // ============================================================

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  final ApiService api = ApiService();

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String emailKey = 'saved_email';
  static const String passwordKey = 'saved_password';
  static const String rememberKey = 'remember_me';

  // ============================================================
  // STATE
  // ============================================================

  bool obscurePassword = true;
  bool rememberMe = false;
  bool loading = false;
  bool checkingSavedLogin = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // GO TO REGISTER
  // ============================================================

  void goToRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  // ============================================================
  // GO TO HOME
  // ============================================================

  void goToHome() {
    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  // ============================================================
  // LOAD SAVED CREDENTIALS
  // ============================================================

  Future<void> loadSavedCredentials() async {
    try {
      final savedRemember = await secureStorage.read(key: rememberKey);

      final savedEmail = await secureStorage.read(key: emailKey);

      final savedPassword = await secureStorage.read(key: passwordKey);

      if (!mounted) return;

      if (savedRemember == 'true' &&
          savedEmail != null &&
          savedPassword != null &&
          savedEmail.trim().isNotEmpty &&
          savedPassword.trim().isNotEmpty) {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;

        setState(() {
          rememberMe = true;
          checkingSavedLogin = false;
        });

        await automaticLogin();
      } else {
        setState(() {
          checkingSavedLogin = false;
        });
      }
    } catch (e) {
      debugPrint('ERROR LOADING SAVED LOGIN: $e');

      if (!mounted) return;

      setState(() {
        checkingSavedLogin = false;
      });
    }
  }

  // ============================================================
  // SAVE CREDENTIALS
  // ============================================================

  Future<void> saveCredentials(String email, String password) async {
    await secureStorage.write(key: emailKey, value: email);

    await secureStorage.write(key: passwordKey, value: password);

    await secureStorage.write(key: rememberKey, value: 'true');
  }

  // ============================================================
  // REMOVE SAVED CREDENTIALS
  // ============================================================

  Future<void> removeSavedCredentials() async {
    await secureStorage.delete(key: emailKey);

    await secureStorage.delete(key: passwordKey);

    await secureStorage.delete(key: rememberKey);
  }

  // ============================================================
  // SAVE LOGGED-IN USER
  // ============================================================

  Future<void> saveLoggedInUser(
    String email,
    Map<String, dynamic> result,
  ) async {
    await secureStorage.write(key: 'logged_in', value: 'true');

    await secureStorage.write(key: 'user_email', value: email);

    await secureStorage.write(key: 'saved_email', value: email);

    final user = result['user'];

    if (user is Map) {
      final name = user['name']?.toString() ?? '';

      await secureStorage.write(key: 'user_name', value: name);

      if (user['id'] != null) {
        await secureStorage.write(key: 'user_id', value: user['id'].toString());
      }
    }
  }

  // ============================================================
  // AUTOMATIC LOGIN
  // ============================================================

  Future<void> automaticLogin() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final email = emailController.text.trim().toLowerCase();

      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        await removeSavedCredentials();

        if (!mounted) return;

        setState(() {
          loading = false;
          rememberMe = false;
        });

        return;
      }

      debugPrint('================================');
      debugPrint('AUTOMATIC LOGIN');
      debugPrint('EMAIL: $email');
      debugPrint('================================');

      final result = await api.login(email: email, password: password);

      final user = result['user'];

      final loggedInEmail =
          user?['email']?.toString() ?? email.trim().toLowerCase();

      await secureStorage.write(key: 'saved_email', value: loggedInEmail);

      debugPrint('AUTOMATIC LOGIN SUCCESS: $result');

      await saveLoggedInUser(email, result);

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      goToHome();
    } catch (e) {
      debugPrint('AUTOMATIC LOGIN FAILED: $e');

      await removeSavedCredentials();

      if (!mounted) return;

      setState(() {
        loading = false;
        rememberMe = false;
      });
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login() async {
    final email = emailController.text.trim().toLowerCase();

    final password = passwordController.text.trim();

    // ==========================================================
    // VALIDATION
    // ==========================================================

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );

      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );

      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );

      return;
    }

    if (!mounted) return;

    setState(() {
      loading = true;
    });

    // ==========================================================
    // CALL FASTAPI
    // ==========================================================

    try {
      debugPrint('================================');
      debugPrint('LOGIN');
      debugPrint('EMAIL: $email');
      debugPrint('================================');

      final result = await api.login(email: email, password: password);

      debugPrint('LOGIN SUCCESS: $result');

      // ========================================================
      // SAVE USER
      // ========================================================

      await saveLoggedInUser(email, result);

      // ========================================================
      // REMEMBER ME
      // ========================================================

      if (rememberMe) {
        await saveCredentials(email, password);
      } else {
        await removeSavedCredentials();
      }

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      // ========================================================
      // HOME
      // ========================================================

      goToHome();
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  void showForgotPassword() {
    final forgotEmailController = TextEditingController(
      text: emailController.text.trim(),
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool sending = false;

        return StatefulBuilder(
          builder: (dialogBuildContext, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF102846),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),

              title: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your email address and we will send you a password reset link.',
                    style: TextStyle(
                      color: Color(0xFF8296B5),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: forgotEmailController,

                    keyboardType: TextInputType.emailAddress,

                    style: const TextStyle(color: Colors.white, fontSize: 13),

                    decoration: InputDecoration(
                      hintText: 'Enter your email',

                      hintStyle: const TextStyle(
                        color: Color(0xFF7186A5),
                        fontSize: 12,
                      ),

                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFF7189AA),
                      ),

                      filled: true,

                      fillColor: const Color(0xFF0B203A),

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
                        borderSide: const BorderSide(
                          color: Color(0xFF3478F6),
                          width: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),

              actions: [
                // ==================================================
                // CANCEL
                // ==================================================
                TextButton(
                  onPressed: sending
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },

                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF8296B5)),
                  ),
                ),

                // ==================================================
                // SEND LINK
                // ==================================================
                ElevatedButton(
                  onPressed: sending
                      ? null
                      : () async {
                          final email = forgotEmailController.text
                              .trim()
                              .toLowerCase();

                          if (email.isEmpty ||
                              !email.contains('@') ||
                              !email.contains('.')) {
                            ScaffoldMessenger.of(
                              dialogBuildContext,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid email address',
                                ),
                              ),
                            );

                            return;
                          }

                          setDialogState(() {
                            sending = true;
                          });

                          try {
                            await api.forgotPassword(email: email);

                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.of(dialogContext).pop();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Password reset link sent to $email',
                                ),
                                backgroundColor: const Color(0xFF1D9B61),
                              ),
                            );
                          } catch (e) {
                            if (!dialogContext.mounted) {
                              return;
                            }

                            setDialogState(() {
                              sending = false;
                            });

                            final message = e.toString().replaceFirst(
                              'Exception: ',
                              '',
                            );

                            ScaffoldMessenger.of(
                              dialogBuildContext,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF216BFF),

                    foregroundColor: Colors.white,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),

                  child: sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Send Link',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      forgotEmailController.dispose();
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // CHECKING SAVED LOGIN
    // ==========================================================

    if (checkingSavedLogin) {
      return const Scaffold(
        backgroundColor: Color(0xFF071A33),

        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF216BFF)),
        ),
      );
    }

    // ==========================================================
    // LOGIN SCREEN
    // ==========================================================

    return Scaffold(
      backgroundColor: const Color(0xFF071A33),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  // ==================================================
                  // LOGO
                  // ==================================================
                  Container(
                    height: 64,
                    width: 64,

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF216BFF), Color(0xFF6C5CE7)],
                      ),

                      borderRadius: BorderRadius.circular(19),

                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF216BFF,
                          ).withValues(alpha: 0.25),
                          blurRadius: 22,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.handyman_rounded,
                      color: Colors.white,
                      size: 31,
                    ),
                  ),

                  const SizedBox(height: 17),

                  // ==================================================
                  // TITLE
                  // ==================================================
                  const Text(
                    'SERVICECONNECT',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Trusted services, near you',

                    textAlign: TextAlign.center,

                    style: TextStyle(color: Color(0xFF8296B5), fontSize: 12),
                  ),

                  const SizedBox(height: 26),

                  // ==================================================
                  // LOGIN CARD
                  // ==================================================
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(21),

                    decoration: BoxDecoration(
                      color: const Color(0xFF102846),

                      borderRadius: BorderRadius.circular(22),

                      border: Border.all(color: const Color(0xFF294566)),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.20),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // ==================================================
                        // WELCOME
                        // ==================================================
                        const Text(
                          'Welcome back 👋',

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Login to continue to ServiceConnect',

                          style: TextStyle(
                            color: Color(0xFF8296B5),
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 21),

                        // ==================================================
                        // EMAIL
                        // ==================================================
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

                        const SizedBox(height: 16),

                        // ==================================================
                        // PASSWORD
                        // ==================================================
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
                          hint: 'Enter your password',
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
                              size: 20,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ==================================================
                        // REMEMBER ME + FORGOT
                        // ==================================================
                        Row(
                          children: [
                            SizedBox(
                              height: 35,
                              width: 35,

                              child: Checkbox(
                                value: rememberMe,

                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value ?? false;
                                  });
                                },

                                activeColor: const Color(0xFF216BFF),

                                checkColor: Colors.white,

                                side: const BorderSide(
                                  color: Color(0xFF7189AA),
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),

                            const Text(
                              'Remember me',

                              style: TextStyle(
                                color: Color(0xFF8296B5),
                                fontSize: 12,
                              ),
                            ),

                            const Spacer(),

                            TextButton(
                              onPressed: showForgotPassword,

                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(35, 35),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),

                              child: const Text(
                                'Forgot password?',

                                style: TextStyle(
                                  color: Color(0xFF4B8BFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // LOGIN BUTTON
                        // ==================================================
                        SizedBox(
                          width: double.infinity,

                          height: 49,

                          child: ElevatedButton(
                            onPressed: loading ? null : login,

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
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.3,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Login',

                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 19),

                        // ==================================================
                        // DIVIDER
                        // ==================================================
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: Color(0xFF294566)),
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 11),

                              child: Text(
                                'OR',

                                style: TextStyle(
                                  color: Color(0xFF7189AA),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const Expanded(
                              child: Divider(color: Color(0xFF294566)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 17),

                        // ==================================================
                        // CREATE ACCOUNT
                        // ==================================================
                        Center(
                          child: TextButton(
                            onPressed: goToRegister,

                            child: const Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",

                                style: TextStyle(
                                  color: Color(0xFF8296B5),
                                  fontSize: 12,
                                ),

                                children: [
                                  TextSpan(
                                    text: 'Create account',

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

                  const SizedBox(height: 18),

                  // ==================================================
                  // FOOTER
                  // ==================================================
                  const Text(
                    'Find trusted professionals for your everyday needs.',

                    textAlign: TextAlign.center,

                    style: TextStyle(color: Color(0xFF607896), fontSize: 10.5),
                  ),
                ],
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
