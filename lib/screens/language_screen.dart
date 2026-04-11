import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easylense_prototype/screens/birthday_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selectedLanguage;
  bool _isSaving = false;

  Future<void> _saveAndProceed() async {
    if (_selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a language')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'language': _selectedLanguage,
        });
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BirthdayScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save language: $e')),
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
                'What is your preferred\nlanguage?',
                style: TextStyle(
                  fontFamily: 'HeaderFont',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              
              const Spacer(),

              // English Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () {
                    setState(() {
                      _selectedLanguage = 'English';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedLanguage == 'English' ? const Color(0xFF08209A) : Colors.white,
                    foregroundColor: _selectedLanguage == 'English' ? Colors.white : const Color(0xFF08209A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    side: const BorderSide(color: Color(0xFF08209A), width: 1.5),
                    elevation: _selectedLanguage == 'English' ? 2 : 0,
                  ),
                  child: const Text(
                    'English',
                    style: TextStyle(
                      fontFamily: 'HeaderFont',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tagalog Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () {
                    setState(() {
                      _selectedLanguage = 'Filipino (Tagalog)';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedLanguage == 'Filipino (Tagalog)' ? const Color(0xFF08209A) : Colors.white,
                    foregroundColor: _selectedLanguage == 'Filipino (Tagalog)' ? Colors.white : const Color(0xFF08209A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    side: const BorderSide(color: Color(0xFF08209A), width: 1.5),
                    elevation: _selectedLanguage == 'Filipino (Tagalog)' ? 2 : 0,
                  ),
                  child: const Text(
                    'Filipino (Tagalog)',
                    style: TextStyle(
                      fontFamily: 'HeaderFont',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const Spacer(),
              const Spacer(),

              // Bottom Pagination & Next arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildDot(false),
                      _buildDot(true),
                      _buildDot(false),
                      _buildDot(false),
                      _buildDot(false),
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
                          onPressed: _selectedLanguage != null ? _saveAndProceed : null,
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
