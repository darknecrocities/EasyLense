import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easylense_prototype/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        setState(() {
          _errorMessage = "Password Incorrect if you don't remember your password reset it";
        });
      } else {
        setState(() {
          _errorMessage = e.message ?? "An error occurred during login.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration fieldDecoration(String hint, IconData icon, {bool isPassword = false, bool isError = false}) {
      return InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'DescriptionFont',
          color: Colors.black38,
        ),
        prefixIcon: Icon(icon, color: isError ? Colors.red : const Color(0xFF08209A)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: isError ? Colors.red : const Color(0xFF08209A),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isError ? Colors.red : const Color(0xFF08209A),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isError ? Colors.red : const Color(0xFF08209A),
            width: 2.0,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // Setting to white as requested for login
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                // Top App bar section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF08209A)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontFamily: 'DescriptionFont',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 48), // Padding equivalent to icon for centering
                  ],
                ),
                const SizedBox(height: 20),
                
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo/secondary_logo.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Label
                const Text(
                  'Email',
                  style: TextStyle(
                    fontFamily: 'HeaderFont',
                    fontSize: 14,
                    color: Color(0xFF08209A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Email Field
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.black87),
                  keyboardType: TextInputType.emailAddress,
                  decoration: fieldDecoration('your.email@example.com', Icons.email),
                ),
                const SizedBox(height: 20),

                // Password Label
                Text(
                  'Password',
                  style: TextStyle(
                    fontFamily: 'HeaderFont',
                    fontSize: 14,
                    color: _errorMessage != null ? Colors.red : const Color(0xFF08209A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Password Field
                TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.black87),
                  obscureText: _obscurePassword,
                  decoration: fieldDecoration(
                    'Enter your password',
                    Icons.lock,
                    isPassword: true,
                    isError: _errorMessage != null,
                  ),
                ),
                
                // Error Message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontFamily: 'DescriptionFont',
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to reset password (to be implemented)
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontFamily: 'HeaderFont',
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Log In Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF08209A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Log In',
                          style: TextStyle(
                            fontFamily: 'HeaderFont',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 32),

                // Or Divider
                Row(
                  children: [
                    Expanded(child: Container(height: 1, color: Colors.grey[400])),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or',
                        style: TextStyle(fontFamily: 'HeaderFont', color: Colors.black54),
                      ),
                    ),
                    Expanded(child: Container(height: 1, color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 32),

                // Google Button
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      // Google Sign In
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      side: const BorderSide(color: Color(0xFF08209A), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/icons/auth_icon/service_icons/google_icons.png', height: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Log In with Google',
                          style: TextStyle(
                            fontFamily: 'HeaderFont',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Facebook Button
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      // Facebook Sign In
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      side: const BorderSide(color: Color(0xFF08209A), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/icons/auth_icon/service_icons/facebook_icons.png', height: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Log In with Facebook',
                          style: TextStyle(
                            fontFamily: 'HeaderFont',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),

                // Don't have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontFamily: 'DescriptionFont',
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to Sign Up (to be implemented)
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontFamily: 'HeaderFont',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF08209A),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
