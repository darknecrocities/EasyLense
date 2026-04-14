import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easylense_prototype/screens/auth/signup_success_screen.dart';
import 'package:easylense_prototype/screens/auth/signup_error_screen.dart';

class SignupVerifyEmailScreen extends StatefulWidget {
  final String email;

  const SignupVerifyEmailScreen({
    super.key,
    required this.email,
  });

  @override
  State<SignupVerifyEmailScreen> createState() => _SignupVerifyEmailScreenState();
}

class _SignupVerifyEmailScreenState extends State<SignupVerifyEmailScreen> {
  Timer? _timer;
  int _countdown = 359; // 5 minutes 59 seconds limit
  bool _canResend = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _sendInitialVerification();
    _startTimer();
  }

  Future<void> _sendInitialVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
      } catch (e) {
        // Silently handle if rate limited or other error on initial send
      }
    }
  }

  void _startTimer() {
    setState(() {
      _countdown = 359;
      _canResend = false;
    });
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
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

  String get _formattedTime {
    int minutes = _countdown ~/ 60;
    int seconds = _countdown % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _resendLink() async {
    if (!_canResend) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification link has been resent!')),
          );
          _startTimer();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to resend: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isChecking = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        // Get the fresh user instance after reload
        User? refreshedUser = FirebaseAuth.instance.currentUser;
        
        if (mounted) {
          if (refreshedUser != null && refreshedUser.emailVerified) {
            _timer?.cancel();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SignupSuccessScreen()),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SignupErrorScreen()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
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
                            'assets/icons/auth_icon/signup_icon/email_sent.png',
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        const Text(
                          'Verify Your Email',
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
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'The Verification mail been sent\non your mailbox',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DescriptionFont',
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Countdown Status Text
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.circle, size: 6, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontFamily: 'DescriptionFont',
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          const TextSpan(text: 'The OTP will expire in '),
                                          TextSpan(
                                            text: _formattedTime,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6.0),
                                    child: Icon(Icons.circle, size: 6, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontFamily: 'DescriptionFont',
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          const TextSpan(text: "Didn't receive the link?\n"),
                                          WidgetSpan(
                                            child: InkWell(
                                              onTap: _canResend ? _resendLink : null,
                                              child: Text(
                                                'Resend',
                                                style: TextStyle(
                                                  fontFamily: 'HeaderFont',
                                                  color: _canResend ? const Color(0xFF08209A) : Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const TextSpan(text: ' or Check your Spam\nfolder'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Verify Action Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isChecking ? null : _checkVerificationStatus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF08209A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: _isChecking
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Verify",
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
