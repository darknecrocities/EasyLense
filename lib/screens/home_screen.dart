import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/settings_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_nav_bar.dart';
import '../widgets/floating_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  CameraController? _cameraController;
  bool _isPermissionGranted = false;
  bool _isInitializing = true;
  
  // Menu Animation
  late AnimationController _menuController;
  late Animation<Offset> _menuAnimation;
  bool _isMenuVisible = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuAnimation = Tween<Offset>(
      begin: const Offset(1.0, -1.0), // Start from top-right outside
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOutBack,
    ));
  }

  void _toggleMenu() {
    setState(() {
      if (_isMenuVisible) {
        _menuController.reverse();
        _isMenuVisible = false;
      } else {
        _isMenuVisible = true;
        _menuController.forward();
      }
    });
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _isPermissionGranted = true;
      });
      await _initializeCamera();
    } else {
      setState(() {
        _isPermissionGranted = false;
        _isInitializing = false;
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: CustomAppBar(onMenuTap: _toggleMenu),
      body: Stack(
        children: [
          // Content based on Index
          _buildBodyContent(),

          // Transparent barrier when menu is open
          if (_isMenuVisible)
            GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),

          // Floating Menu Overlay (Slides from top right)
          Positioned(
            top: 10,
            right: 16,
            child: SlideTransition(
              position: _menuAnimation,
              child: _isMenuVisible 
                ? FloatingMenu(onClose: _toggleMenu)
                : const SizedBox.shrink(),
            ),
          ),

          // Navigation bar
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeDashboard();
      case 1:
        return const Center(child: Text('Navigation Assist Placeholder'));
      case 2:
        return const Center(child: Text('Devices Placeholder'));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHomeDashboard() {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF08209A)));
    }
    if (!_isPermissionGranted) {
      return _buildPermissionDeniedCard();
    }
    return _buildCameraFeed();
  }

  Widget _buildPermissionDeniedCard() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.photo_camera_outlined,
                size: 100,
                color: Color(0xFF08209A),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Enable camera\npermissions in your\ndevice settings to view\nthe live feed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'HeaderFont',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkPermissions,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF08209A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraFeed() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF08209A)));
    }
    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(_cameraController!)),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 24,
          bottom: 150,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF08209A),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.cyanAccent, Colors.purpleAccent, Colors.orangeAccent],
                ).createShader(bounds),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
