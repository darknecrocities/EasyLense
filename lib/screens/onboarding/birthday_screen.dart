import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easylense_prototype/screens/onboarding/visual_condition_screen.dart';

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({super.key});

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  DateTime _selectedDate = DateTime(1990, 1, 1);
  bool _isSaving = false;

  Future<void> _saveAndProceed() async {
    setState(() {
      _isSaving = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'birthday': Timestamp.fromDate(_selectedDate),
        });
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VisualConditionScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save birthday: $e')),
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
                'When is your birthday?',
                style: TextStyle(
                  fontFamily: 'HeaderFont',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              
              const Spacer(),

              // Birthday Picker
              SizedBox(
                height: 300,
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontFamily: 'HeaderFont',
                        fontSize: 20,
                        color: Color(0xFF08209A),
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _selectedDate,
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        _selectedDate = newDateTime;
                      });
                    },
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
                      _buildDot(false),
                      _buildDot(true),
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
