import 'package:flutter/material.dart';

class FloatingMenu extends StatelessWidget {
  final VoidCallback onClose;

  const FloatingMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Image.asset(
                    'assets/icons/hamburger-menu-icons/main-logo.png',
                    height: 95, // Increased slightly from 60 for better visibility
                    fit: BoxFit.contain,
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF08209A), width: 2.5),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFF08209A),
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Item: Profile
            _buildMenuItem(
              icon: 'assets/icons/hamburger-menu-icons/profile.png',
              label: 'Profile',
              onTap: () {},
            ),
            const Divider(height: 1, thickness: 1.5, indent: 20, endIndent: 20),

            // Item: Alert History
            _buildMenuItem(
              icon: 'assets/icons/hamburger-menu-icons/notification.png',
              label: 'Alert History',
              onTap: () {},
            ),
            const Divider(height: 1, thickness: 1.5, indent: 20, endIndent: 20),

            // Item: Settings
            _buildMenuItem(
              icon: 'assets/icons/hamburger-menu-icons/settings.png',
              label: 'Settings',
              onTap: () {},
            ),
            const SizedBox(height: 9),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Image.asset(
              icon,
              height: 32, // Larger icons like mockup
              width: 32,
              color: const Color(0xFF08209A),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'HeaderFont',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
