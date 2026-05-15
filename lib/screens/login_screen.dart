import 'package:expense_tracker/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'expense_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ExpenseListScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Login failed. Please check your credentials.';
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFE53935);
    const backgroundWhite = Colors.white;
    const textDark = Color(0xFF2D2D2D);
    const textGrey = Color(0xFF757575);

    return Scaffold(
      backgroundColor: backgroundWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔴 Logo / App Name
                  const Icon(
                    Icons.receipt_long_rounded,
                    size: 80,
                    color: primaryRed,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Expense Tracker',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: TextStyle(fontSize: 14, color: textGrey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // 📧 Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your email';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 🔐 Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your password';
                      if (v.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),

                  // ❌ Error Message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 🔴 Login Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔗 Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Don\'t have an account?', style: TextStyle(color: textGrey)),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()), // ✅ Navigate to RegisterScreen
                        ),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}