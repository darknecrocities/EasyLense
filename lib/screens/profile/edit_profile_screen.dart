import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/cloudflare_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _visualCondition = 'Macular Degeneration';
  final List<String> _conditions = [
    'Prefer not to say',
    'Macular Degeneration',
    'Cataracts',
    'Glaucoma',
    'Diabetic Retinopathy',
    'Other'
  ];

  String? _photoUrl;
  File? _newImageFile;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  String _safeString(dynamic value, String fallback) {
    if (value == null) return fallback;
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.month}/${date.day}/${date.year}';
    }
    return value.toString();
  }

  Future<void> _fetchProfileData() async {
    if (currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (mounted) {
          setState(() {
            _firstNameController.text = _safeString(data['firstName'], '');
            _lastNameController.text = _safeString(data['lastName'], '');
            _emailController.text = _safeString(data['email'], currentUser?.email ?? '');
            _phoneController.text = _safeString(data['phoneNumber'], '');
            _birthdayController.text = _safeString(data['birthday'], '');
            _emergencyContactController.text = _safeString(data['emergencyContact'], '');
            
            if (data['visualCondition'] != null) {
               final vc = _safeString(data['visualCondition'], '');
               if (_conditions.contains(vc)) {
                 _visualCondition = vc;
               }
            }
            if (data['photoUrl'] != null) {
              _photoUrl = data['photoUrl'].toString();
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (currentUser == null) return;
    
    // Check password logic
    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
        return;
      }
      if (_passwordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password too short')));
        return;
      }
    }

    setState(() => _isSaving = true);
    
    try {
      String? finalPhotoUrl = _photoUrl;

      // Upload new image if selected
      if (_newImageFile != null) {
        if (_photoUrl != null) {
          await CloudflareService.deleteProfileImage(_photoUrl!);
        }
        final uploadedUrl = await CloudflareService.uploadProfileImage(_newImageFile!, currentUser!.uid);
        if (uploadedUrl != null) {
          finalPhotoUrl = uploadedUrl;
        }
      }

      // Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'birthday': _birthdayController.text.trim(),
        'emergencyContact': _emergencyContactController.text.trim(),
        'visualCondition': _visualCondition,
        'photoUrl': finalPhotoUrl,
      });

      // Update email in Auth if changed
      if (_emailController.text.trim().isNotEmpty && _emailController.text.trim() != currentUser!.email) {
        await currentUser!.updateEmail(_emailController.text.trim());
      }

      // Update password in Auth if requested
      if (_passwordController.text.isNotEmpty) {
        await currentUser!.updatePassword(_passwordController.text);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF08209A))),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header Section with Overlapping Avatar
            SizedBox(
              height: 280,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Blue Background
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 200,
                      color: const Color(0xFF08209A),
                      padding: const EdgeInsets.only(top: 50, left: 20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF08209A),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Profile Avatar
                  Positioned(
                    top: 100,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8), // White border around avatar
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 80,
                              backgroundColor: const Color(0xFF08209A),
                              backgroundImage: _newImageFile != null
                                  ? FileImage(_newImageFile!) as ImageProvider
                                  : (_photoUrl != null ? NetworkImage(_photoUrl!) : null),
                              child: _newImageFile == null && _photoUrl == null
                                  ? Image.asset(
                                      'assets/icons/auth_icon/signup_icon/profile_icon.png',
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Change Photo Button
            GestureDetector(
              onTap: _pickImage,
              child: const Text(
                'Change Photo',
                style: TextStyle(
                  fontFamily: 'HeaderFont',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF08209A),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Edit Forms
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Name'),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('First Name', null, controller: _firstNameController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('Last Name', null, controller: _lastNameController)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildLabel('Email'),
                  _buildTextField('your.email@example.com', Icons.email, controller: _emailController),
                  const SizedBox(height: 16),
                  
                  _buildLabel('Phone Number'),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF08209A), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            children: [
                              const Text('🇵🇭', style: TextStyle(fontSize: 20)),
                              const Icon(Icons.arrow_drop_down, color: Color(0xFF08209A)),
                              Container(width: 1, height: 24, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: '+63 123 456 7890',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontFamily: 'DescriptionFont',
                                color: Colors.black38,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildLabel('Birthday'),
                  _buildTextField('MM/DD/YYYY', Icons.calendar_today, controller: _birthdayController),
                  const SizedBox(height: 16),
                  
                  _buildLabel('Visual Condition'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF08209A), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.visibility, color: Color(0xFF08209A)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _visualCondition,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF08209A), size: 30),
                              items: _conditions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      fontFamily: 'DescriptionFont',
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _visualCondition = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildLabel('Password'),
                  _buildTextField(
                    'Enter your password', 
                    Icons.lock, 
                    isPassword: true, 
                    obscure: _obscurePassword,
                    onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildLabel('Confirm Password'),
                  _buildTextField(
                    'Confirm Password', 
                    Icons.lock, 
                    isPassword: true, 
                    obscure: _obscureConfirmPassword,
                    onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    controller: _confirmPasswordController,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF08209A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontFamily: 'HeaderFont',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'DescriptionFont',
          fontSize: 12,
          color: Color(0xFF08209A),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, 
    IconData? icon, {
    bool isPassword = false, 
    bool obscure = false,
    VoidCallback? onToggleObscure,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'DescriptionFont',
          color: Colors.black38,
        ),
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF08209A)) : null,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF08209A),
                ),
                onPressed: onToggleObscure,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF08209A), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF08209A), width: 2.0),
        ),
      ),
    );
  }
}
