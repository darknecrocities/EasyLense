import 'package:flutter/material.dart';
import '../common/spotlight_target.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final GlobalKey? homeKey;
  final GlobalKey? navKey;
  final GlobalKey? devicesKey;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.homeKey,
    this.navKey,
    this.devicesKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFF08209A),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'assets/icons/navbar-icon/home.png', 'Home', homeKey),
          _buildNavItem(1, 'assets/icons/navbar-icon/navigation.png', 'Navigation', navKey),
          _buildNavItem(2, 'assets/icons/navbar-icon/glasses.png', 'Devices', devicesKey),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String assetPath, String label, GlobalKey? key) {
    final bool isActive = currentIndex == index;

    return Expanded(
      child: SpotlightTarget(
        id: 'nav_${label.toLowerCase()}',
        child: GestureDetector(
          key: key,
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              boxShadow: isActive ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  assetPath,
                  height: 22,
                  color: isActive ? const Color(0xFF08209A) : Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'HeaderFont',
                    color: isActive ? const Color(0xFF08209A) : Colors.white.withOpacity(0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
