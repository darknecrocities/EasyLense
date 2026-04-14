import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easylense_prototype/screens/main/home_screen.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  bool _voiceFeedback = true;
  bool _hapticFeedback = true;
  bool _darkMode = false;
  bool _isSaving = false;

  Future<void> _saveAndProceed() async {
    setState(() {
      _isSaving = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'voiceFeedback': _voiceFeedback,
          'hapticFeedback': _hapticFeedback,
          'darkMode': _darkMode,
          'setupComplete': true,
        });
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildToggleRow(String title, bool value, Color activeColor, Function(bool) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'HeaderFont',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF08209A), width: 1.5),
            color: Colors.white,
          ),
          child: Row(
            children: [
              // On Button
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(true),
                  child: Container(
                    decoration: BoxDecoration(
                      color: value ? activeColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'On',
                      style: TextStyle(
                        fontFamily: 'HeaderFont',
                        fontWeight: FontWeight.bold,
                        color: value ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              // Off Button
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(false),
                  child: Container(
                    decoration: BoxDecoration(
                      color: !value 
                        ? (title == 'Dark Mode' ? const Color(0xFFFF5252) : const Color(0xFFE0E0E0)) 
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Off',
                      style: TextStyle(
                        fontFamily: 'HeaderFont',
                        fontWeight: FontWeight.bold,
                        color: !value ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              
              const Text(
                'Accessibility Settings',
                style: TextStyle(
                  fontFamily: 'HeaderFont',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 48),

              // Voice Feedback Toggle
              _buildToggleRow(
                'Voice Feedback', 
                _voiceFeedback, 
                const Color(0xFF4CAF50), // Green for On
                (val) => setState(() => _voiceFeedback = val)
              ),
              const SizedBox(height: 24),

              // Haptic Feedback Toggle
              _buildToggleRow(
                'Haptic Feedback', 
                _hapticFeedback, 
                const Color(0xFF4CAF50), // Green for On
                (val) => setState(() => _hapticFeedback = val)
              ),
              const SizedBox(height: 24),

              // Dark Mode Toggle
              _buildToggleRow(
                'Dark Mode', 
                _darkMode, 
                const Color(0xFF4CAF50), // Standard green if On? Mock shows Red for OFF.
                (val) => setState(() => _darkMode = val)
              ),

              const Spacer(),

              // Bottom Pagination & Next arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildDot(false),
                      _buildDot(false),
                      _buildDot(false),
                      _buildDot(false),
                      _buildDot(true),
                      _buildDot(false),
                    ],
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF08209A),
                      shape: BoxShape.circle,
                    ),
                    child: _isSaving 
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.white),
                          onPressed: _saveAndProceed,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF08209A) : Colors.transparent,
        shape: BoxShape.circle,
        border: isActive ? null : Border.all(color: const Color(0xFF08209A), width: 1),
      ),
    );
  }
}
