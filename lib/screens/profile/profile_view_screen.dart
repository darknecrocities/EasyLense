import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  String _firstName = 'FirstName';
  String _lastName = 'LastName';
  String _email = 'your.email@example.com';
  String _phone = '+63 123 456 7890';
  String _birthday = '9/20/1998';
  String _visualCondition = 'Prefer not to say';
  String _emergencyContact = 'Mama';
  String? _photoUrl;
  
  bool _isLoading = true;

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
            _firstName = _safeString(data['firstName'], _firstName);
            _lastName = _safeString(data['lastName'], _lastName);
            _email = _safeString(data['email'], currentUser?.email ?? _email);
            _phone = _safeString(data['phoneNumber'], _phone);
            _birthday = _safeString(data['birthday'], _birthday);
            _visualCondition = _safeString(data['visualCondition'], _visualCondition);
            _emergencyContact = _safeString(data['emergencyContact'], _emergencyContact);
            
            // Only assign photoUrl if not null
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F8FA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF08209A))),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
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
                    child: Container(
                      padding: const EdgeInsets.all(8), // White border around avatar
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: const Color(0xFF08209A),
                        backgroundImage: _photoUrl != null 
                            ? NetworkImage(_photoUrl!) as ImageProvider
                            : null,
                        child: _photoUrl == null
                            ? Image.asset(
                                'assets/icons/auth_icon/signup_icon/profile_icon.png',
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Name Header
            Text(
              '$_firstName $_lastName',
              style: const TextStyle(
                fontFamily: 'DescriptionFont', // Match mockups monospace-like aesthetics
                fontSize: 18,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            
            // Profile Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildProfileRow(Icons.email_outlined, 'Email', _email),
                    const Divider(height: 1, indent: 24, endIndent: 24),
                    _buildProfileRow(Icons.phone_outlined, 'Phone Number', _phone),
                    const Divider(height: 1, indent: 24, endIndent: 24),
                    _buildProfileRow(Icons.calendar_today_outlined, 'Birthday', _birthday),
                    const Divider(height: 1, indent: 24, endIndent: 24),
                    _buildProfileRow(Icons.visibility_outlined, 'Visual Condition', _visualCondition),
                    const Divider(height: 1, indent: 24, endIndent: 24),
                    _buildProfileRow(
                      Icons.person_outline, 
                      'Emergency Contact', 
                      _emergencyContact,
                      hasArrow: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Edit Profile Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // Navigate to edit screen and refetch on pop
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                    _fetchProfileData(); // refresh data
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF08209A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontFamily: 'HeaderFont',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value, {bool hasArrow = false}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF08209A).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF08209A), size: 20),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'DescriptionFont',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'DescriptionFont',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (hasArrow)
            const Icon(Icons.chevron_right, color: Colors.black87),
        ],
      ),
    );
  }
}
