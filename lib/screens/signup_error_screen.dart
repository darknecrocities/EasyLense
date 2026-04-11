import 'package:flutter/material.dart';

class SignupErrorScreen extends StatelessWidget {
  const SignupErrorScreen({super.key});

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
                        const Spacer(),

                        // Error X Icon
                        Center(
                          child: Image.asset(
                            'assets/icons/auth_icon/signup_icon/x.png',
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Title text
                        const Text(
                          'You have not successfully\nverified your account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'HeaderFont',
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        
                        const Spacer(),

                        // Back to Sign Up Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              // We just pop back to the check verify screen so they can resend the link or hit verify again
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF08209A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Back to Sign Up', // Per standard mock
                              style: TextStyle(
                                fontFamily: 'HeaderFont',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
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
