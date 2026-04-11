import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easylense_prototype/screens/check_email_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your email address";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => CheckEmailScreen(email: email)),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message ?? "Failed to send reset link";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "An unexpected error occurred";
        });
      }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        // App bar section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF08209A),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),
                        
                        const Spacer(),

                        // Hero Icon
                        Center(
                          child: Image.asset(
                            'assets/icons/auth_icon/forgot-password-icon/forgot_lock.png',
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        const Text(
                          'Forgot Password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'HeaderFont',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Color(0xFF08209A),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Subtitle
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'Please enter the email address associated with your account.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DescriptionFont',
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

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

                        // Email Input
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.black87),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'your.email@example.com',
                            hintStyle: const TextStyle(
                              fontFamily: 'DescriptionFont',
                              color: Colors.black38,
                            ),
                            prefixIcon: Icon(Icons.email, color: _errorMessage != null ? Colors.red : const Color(0xFF08209A)),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _errorMessage != null ? Colors.red : const Color(0xFF08209A),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _errorMessage != null ? Colors.red : const Color(0xFF08209A),
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),

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
                        
                        const SizedBox(height: 24),

                        // Send Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendResetLink,
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
                                  'Send',
                                  style: TextStyle(
                                    fontFamily: 'HeaderFont',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                          ),
                        ),

                        const Spacer(),
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
