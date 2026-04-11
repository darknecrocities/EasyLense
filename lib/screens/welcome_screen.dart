import 'package:flutter/material.dart';
import 'package:easylense_prototype/screens/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Color _backgroundColor = Colors.black;
  bool _showText = true;
  bool _showLogo = false;

  @override
  void initState() {
    super.initState();
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // 1. Initial wait
    await Future.delayed(const Duration(seconds: 2));

    // 2. Transition background from black to white, fade out text, fade in logo
    if (mounted) {
      setState(() {
        _backgroundColor = Colors.white;
        _showText = false;
        _showLogo = true;
      });
    }

    // 3. Wait a bit while showing logo
    await Future.delayed(const Duration(seconds: 2));

    // 4. Navigate to home screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        color: _backgroundColor,
        child: Stack(
          children: [
            // Center the content
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _showText ? 1.0 : 0.0,
                child: const Text(
                  'EasyLens',
                  style: TextStyle(
                    fontFamily: 'HeaderFont',
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _showLogo ? 1.0 : 0.0,
                child: Image.asset(
                  'assets/images/logo/easylens_logo.png',
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
