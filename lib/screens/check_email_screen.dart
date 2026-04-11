import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easylense_prototype/screens/password_reset_success_screen.dart';

class CheckEmailScreen extends StatefulWidget {
  final String email;

  const CheckEmailScreen({
    super.key,
    required this.email,
  });

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  Timer? _timer;
  int _countdown = 25;
  bool _canResend = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _countdown = 25;
      _canResend = false;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _resendLink() async {
    if (!_canResend) return;

    setState(() {
      _isResending = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset link has been resent!')),
        );
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                            'assets/icons/auth_icon/forgot-password-icon/email_sent.png',
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        const Text(
                          'Check Your Email',
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'We have sent a password reset link to\n${widget.email}. Please check your inbox.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'DescriptionFont',
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Resend Link Button
                        SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _canResend && !_isResending ? _resendLink : null,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              side: BorderSide(
                                color: _canResend ? const Color(0xFF08209A) : Colors.grey, 
                                width: 1.5,
                              ),
                            ),
                            child: _isResending 
                              ? const SizedBox(
                                  height: 24, 
                                  width: 24, 
                                  child: CircularProgressIndicator(strokeWidth: 2)
                                )
                              : Text(
                                  _canResend ? 'Resend link' : 'Resend link ($_countdown sec)',
                                  style: TextStyle(
                                    fontFamily: 'HeaderFont',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: _canResend ? const Color(0xFF08209A) : Colors.grey,
                                  ),
                                ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Prototype Action: I've Reset My Password Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const PasswordResetSuccessScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF08209A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "I've reset my password",
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
