import 'package:flutter/material.dart';
import 'package:easylense_prototype/screens/auth/login_screen.dart';
import 'package:easylense_prototype/screens/auth/signup_screen.dart';

class AuthGatewayScreen extends StatelessWidget {
  const AuthGatewayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Centered Logo
              Center(
                child: Image.asset(
                  'assets/images/logo/secondary_logo.png',
                  height: 180, // Slightly larger than login screen for emphasis
                  fit: BoxFit.contain,
                ),
              ),
              
              const Spacer(), // Pushes the buttons to the bottom
              
              // Sign Up Button
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    side: const BorderSide(color: Color(0xFF08209A), width: 2.0),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontFamily: 'HeaderFont',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF08209A),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Log In Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
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
              
              // Terms of Service and Privacy Policy
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'DescriptionFont',
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  children: [
                    TextSpan(text: 'By continuing, you agree to our\n'),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        fontFamily: 'HeaderFont',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF08209A),
                      ),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        fontFamily: 'HeaderFont',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF08209A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
