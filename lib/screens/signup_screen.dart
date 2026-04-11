import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easylense_prototype/screens/signup_verify_email_screen.dart';
import 'package:easylense_prototype/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Validation States
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  void _validateAndSubmit() {
    setState(() {
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;

    if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
      setState(() => _emailError = "Please enter a valid email address.");
      isValid = false;
    }
    
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _phoneError = "Please enter your phone number.");
      isValid = false;
    }

    if (_passwordController.text.trim().length < 6) {
      setState(() => _passwordError = "Password must be at least 6 characters.");
      isValid = false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = "Error: Password does not match.");
      isValid = false;
    }

    if (isValid) {
      _showPrivacyTermsModal();
    }
  }

  void _showPrivacyTermsModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF08209A)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Icon(
                  Icons.privacy_tip_outlined,
                  size: 64,
                  color: Color(0xFF08209A),
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Privacy & Terms',
                  style: TextStyle(
                    fontFamily: 'HeaderFont',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Color(0xFF08209A),
                  ),
                ),
                const SizedBox(height: 16),
                
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF9E7), // Light yellowish background
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF39C12).withOpacity(0.2), width: 1), // Subtle warm border
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Text(
                      "Your privacy is our priority. EasyLens uses on-device AI for real-time detection. We do not store your camera feed or location data in the cloud. By continuing, you agree to our Terms of ServiceYour privacy is our priority. EasyLens uses on-device AI for real-time detection. We do not store your camera feed or location data in the cloud. By continuing, you agree to our Terms of ServiceYour privacy is our priority. EasyLens uses on-device AI for real-time detection. We do not store your camera feed or location data in the cloud. By continuing, you agree to our Terms of ServiceYour privacy is our priority. EasyLens uses on-device AI for real-time detection. We do not store your camera feed or location data in the cloud. By continuing, you agree to our Terms of Service",
                      style: const TextStyle(
                        fontFamily: 'DescriptionFont',
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close modal
                      _executeSignup(); // Proceed to Firebase
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      side: const BorderSide(color: Color(0xFF08209A), width: 2),
                    ),
                    child: const Text(
                      'I agree',
                      style: TextStyle(
                        fontFamily: 'HeaderFont',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF08209A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _executeSignup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save user details to Firestore
      if (userCredential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Successfully created account
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => SignupVerifyEmailScreen(email: _emailController.text.trim())),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          _emailError = "Error: This email address is already registered";
        });
      } else {
        setState(() {
          _emailError = e.message ?? "Signup failed.";
        });
      }
      
      // We aren't doing SMS auth so phone-already-in-use isn't a default Firebase Auth exception for email/password.
      // But we mapped email-already-in-use to show the exact red UI from the mockups.
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Helper for generating standard text fields
  Widget _buildTextField(
    String hint, 
    TextEditingController controller, 
    IconData? prefixIcon, {
    bool isPassword = false, 
    bool obscureParams = false,
    VoidCallback? onToggleObscure,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    bool hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: isPassword ? obscureParams : false,
          keyboardType: keyboardType,
          style: TextStyle(color: hasError ? Colors.red : Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'DescriptionFont',
              color: hasError ? Colors.red[300] : Colors.black38,
            ),
            prefixIcon: prefixIcon != null 
                ? Icon(prefixIcon, color: hasError ? Colors.red : const Color(0xFF08209A))
                : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureParams ? Icons.visibility_off : Icons.visibility,
                      color: hasError ? Colors.red : const Color(0xFF08209A),
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFF08209A),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFF08209A),
                width: 2.0,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Text(
              errorText,
              style: const TextStyle(
                fontFamily: 'DescriptionFont',
                color: Colors.red,
                fontSize: 12,
              ),
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
                        // Back button
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
                        
                        // Logo
                        Center(
                          child: Image.asset(
                            'assets/images/logo/secondary_logo.png',
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Names Form
                        const Text('Name', style: TextStyle(fontFamily: 'HeaderFont', fontSize: 12, color: Color(0xFF08209A), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(child: _buildTextField('First Name', _firstNameController, null)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('Last Name', _lastNameController, null)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Email Form
                        Text('Email', style: TextStyle(fontFamily: 'HeaderFont', fontSize: 12, color: _emailError != null ? Colors.red : const Color(0xFF08209A), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        _buildTextField('your.email@example.com', _emailController, Icons.email, errorText: _emailError, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 12),

                        // Phone Form
                        Text('Phone Number', style: TextStyle(fontFamily: 'HeaderFont', fontSize: 12, color: _phoneError != null ? Colors.red : const Color(0xFF08209A), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: _phoneError != null ? Colors.red : const Color(0xFF08209A), width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
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
                                    Text('+63', style: TextStyle(color: _phoneError != null ? Colors.red : const Color(0xFF08209A), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(color: _phoneError != null ? Colors.red : Colors.black87),
                                  decoration: InputDecoration(
                                    hintText: '123 456 7890',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      fontFamily: 'DescriptionFont',
                                      color: _phoneError != null ? Colors.red[300] : Colors.black38,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_phoneError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                            child: Text(
                              _phoneError!,
                              style: const TextStyle(
                                fontFamily: 'DescriptionFont',
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),

                        // Password Form
                        Text('Password', style: TextStyle(fontFamily: 'HeaderFont', fontSize: 12, color: _passwordError != null ? Colors.red : const Color(0xFF08209A), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        _buildTextField(
                          'Enter your password', 
                          _passwordController, 
                          Icons.lock, 
                          isPassword: true, 
                          obscureParams: _obscurePassword,
                          errorText: _passwordError,
                          onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword)
                        ),
                        const SizedBox(height: 12),

                        // Confirm Password Form
                        Text('Confirm Password', style: TextStyle(fontFamily: 'HeaderFont', fontSize: 12, color: _confirmPasswordError != null ? Colors.red : const Color(0xFF08209A), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        _buildTextField(
                          'Confirm Password', 
                          _confirmPasswordController, 
                          Icons.lock, 
                          isPassword: true, 
                          obscureParams: _obscureConfirmPassword,
                          errorText: _confirmPasswordError,
                          onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)
                        ),
                        const SizedBox(height: 24),

                        // Sign Up Button
                        SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _validateAndSubmit,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF08209A), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: _isLoading 
                              ? const CircularProgressIndicator(color: Color(0xFF08209A))
                              : const Text(
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
                        const SizedBox(height: 20),

                        // Or Divider
                        Row(
                          children: [
                            Expanded(child: Container(height: 1, color: Colors.grey[400])),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Or',
                                style: TextStyle(fontFamily: 'HeaderFont', color: Colors.black54),
                              ),
                            ),
                            Expanded(child: Container(height: 1, color: Colors.grey[400])),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Google Button
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              side: const BorderSide(color: Color(0xFF08209A), width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/icons/auth_icon/service_icons/google_icons.png', height: 20),
                                const SizedBox(width: 12),
                                const Text(
                                  'Log In with Google',
                                  style: TextStyle(
                                    fontFamily: 'HeaderFont',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Facebook Button
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              side: const BorderSide(color: Color(0xFF08209A), width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/icons/auth_icon/service_icons/facebook_icons.png', height: 20),
                                const SizedBox(width: 12),
                                const Text(
                                  'Log In with Facebook',
                                  style: TextStyle(
                                    fontFamily: 'HeaderFont',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const Spacer(),

                        // Already have an account text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(
                                fontFamily: 'DescriptionFont',
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontFamily: 'HeaderFont',
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF08209A),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
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
