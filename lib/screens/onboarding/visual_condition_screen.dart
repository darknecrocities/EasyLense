import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easylense_prototype/screens/main/accessibility_screen.dart';

class VisualConditionScreen extends StatefulWidget {
  const VisualConditionScreen({super.key});

  @override
  State<VisualConditionScreen> createState() => _VisualConditionScreenState();
}

class _VisualConditionScreenState extends State<VisualConditionScreen> {
  String? _selectedCondition;
  bool _isSaving = false;

  final List<String> _conditions = [
    'Macular Degeneration',
    'Glaucoma / Tunnel Vision',
    'Cataracts',
    'Diabetic Retinopathy',
    'Photophobia',
    'Color Vision Deficiency',
    'Unlisted / Prefer not to say',
  ];

  Future<void> _saveAndProceed() async {
    if (_selectedCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a condition')),
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
          'visualCondition': _selectedCondition,
        });
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AccessibilityScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save visual condition: $e')),
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
                'What is your visual\ncondition?',
                style: TextStyle(
                  fontFamily: 'HeaderFont',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 32),

              // Conditions List
              Expanded(
                child: ListView.separated(
                  itemCount: _conditions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final condition = _conditions[index];
                    final isSelected = _selectedCondition == condition;
                    
                    return SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : () {
                          setState(() {
                            _selectedCondition = condition;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? const Color(0xFF08209A) : Colors.white,
                          foregroundColor: isSelected ? Colors.white : const Color(0xFF08209A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          side: const BorderSide(color: Color(0xFF08209A), width: 1.5),
                        ),
                        child: Text(
                          condition,
                          style: const TextStyle(
                            fontFamily: 'HeaderFont',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Bottom Pagination & Next arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildDot(false),
                      _buildDot(false),
                      _buildDot(false),
                      _buildDot(true),
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
                          onPressed: _selectedCondition != null ? _saveAndProceed : null,
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
