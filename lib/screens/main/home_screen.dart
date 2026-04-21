import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';
import '../../providers/settings_provider.dart';
import '../../widgets/navigation/custom_app_bar.dart';
import '../../widgets/navigation/custom_nav_bar.dart';
import '../../widgets/navigation/floating_menu.dart';
import '../../widgets/common/dashboard_walkthrough.dart';
import '../../widgets/dashboard/scanning_dashboard_view.dart';
import '../../widgets/navigation/navigation_view.dart';
import '../../widgets/devices/devices_view.dart';
import '../../widgets/common/spotlight_target.dart';
import '../../providers/navigation_provider.dart';
import '../../services/walkthrough_service.dart';
import '../../controllers/voice_command_controller.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isPermissionGranted = false;
  bool _isInitializing = true;
  Offset _fabPosition = const Offset(-1, -1);

  final GlobalKey _statusKey = GlobalKey();
  final GlobalKey _batteryKey = GlobalKey();
  final GlobalKey _menuKey = GlobalKey();
  final GlobalKey _cameraPlaceholderKey = GlobalKey();
  final GlobalKey _geminiButtonKey = GlobalKey();
  final GlobalKey _glassesCardKey = GlobalKey();
  final GlobalKey _glassesImageKey = GlobalKey();
  final GlobalKey _scanningCardKey = GlobalKey();
  final GlobalKey _statsRowKey = GlobalKey();
  final GlobalKey _homeTabKey = GlobalKey();
  final GlobalKey _navTabKey = GlobalKey();
  final GlobalKey _devicesTabKey = GlobalKey();

  bool _showWalkthrough = false;
  int _tutorialStepIndex = 0;
  bool _isTutorialConnectedMock = false;

  late AnimationController _menuController;
  late Animation<Offset> _menuAnimation;
  bool _isMenuVisible = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _checkWalkthrough();
    
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuAnimation = Tween<Offset>(
      begin: const Offset(1.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOutBack,
    ));
  }

  Future<void> _checkWalkthrough() async {
    final shouldShow = await WalkthroughService.shouldShowDashboardTutorial();
    if (mounted) {
      setState(() => _showWalkthrough = shouldShow);
    }
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
      setState(() => _isPermissionGranted = true);
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
      _cameraController = CameraController(cameras[0], ResolutionPreset.medium, enableAudio: false);
      await _cameraController!.initialize();
      if (mounted) setState(() => _isInitializing = false);
    } catch (e) {
      if (mounted) setState(() => _isInitializing = false);
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
    final walkthroughSteps = [
      TutorialStep(
        title: 'Welcome to Your\nDashboard!',
        description: 'Think of the Dashboard as your home base. This is the main screen you\'ll use every day to connect with your surroundings and get real-time audio and vibration alerts. Click the arrow for a quick tour of what everything does:',
        assetPath: 'assets/images/logo/easylens_logo.png',
      ),
      TutorialStep(
        title: 'Side Settings',
        description: 'Tap those three lines anytime to open your settings, view notifications or profile, where you can adjust your voice alerts, or set up emergency contacts.',
        targetId: 'app_menu',
      ),
      TutorialStep(
        title: 'Connection Status',
        description: 'See that dark blue area at the top left? The red dot means your glasses are currently disconnected. If you want to connect them, just tap right there or head over to the Devices tab at the bottom.',
        targetId: 'app_status',
      ),
      TutorialStep(
        title: 'Backup Camera',
        description: 'Because your glasses aren\'t connected, EasyLens needs your permission to use your phone\'s camera instead. Just pop into your phone\'s settings to allow access, and this middle area will turn into your live backup scanner!',
        targetId: 'camera_placeholder',
      ),
      TutorialStep(
        title: 'Dashboard Preview',
        description: 'This is what you should expect once you successfully connect your smart glasses—your phone screen transforms from a setup menu into your real-time navigation command center!',
      ),
      TutorialStep(
        title: 'Active Connection',
        description: 'Up at the top, you\'ll notice that the red dot has turned green! "Glasses Connected" lets you know you are actively paired. A battery indicator also appears here now...',
        targetId: 'app_status',
      ),
      TutorialStep(
        title: 'Glasses Information',
        description: 'Right below that, you will see your connected "EasyLens Model 1" glasses, confirming exactly which device is currently acting as your "eyes."',
        targetId: 'glasses_image',
      ),
      TutorialStep(
        title: 'Scanning Environment',
        description: 'See that animated radar? That means the EasyLens AI is actively "Scanning Environment..." looking for stairs, vehicles, or obstacles in your path. As soon as it spots a hazard, that radar animation will instantly transform to show you exactly what was detected!',
        targetId: 'scanning_card',
      ),
      TutorialStep(
        title: 'Quick Breakdown',
        description: 'Below the radar, you get a quick breakdown of your current walk. It logs how many Objects have been identified, total Scans performed, and how many critical Alerts were sent to you.',
        targetId: 'stats_row',
      ),
      TutorialStep(
        title: 'Intelligent AI Assist',
        description: 'Just like when you are using your phone live camera feed, you can activate Gemini here too! Tap this button, and your AI assistant will look through your smart glasses to give you a rich, detailed audio description of exactly what is happening in front of you!',
        targetId: 'gemini_button',
      ),
      TutorialStep(
        title: 'Navigation Assist',
        description: 'Ready to head out? Tap this to open your map, punch in a destination (like Holy Angel University!), and get friendly, turn-by-turn voice directions.',
        targetId: 'nav_navigation',
      ),
      TutorialStep(
        title: 'Manage Devices',
        description: 'Need to check your glasses battery life or reconnect them? Tap this to manage all your hardware settings.',
        targetId: 'nav_devices',
      ),
      TutorialStep(
        title: "You're All Set!",
        description: "That's basically everything you need to know. The rest is just you stepping out and navigating with confidence. Connect your glasses, and let's get moving.",
        assetPath: 'assets/images/logo/secondary_logo.png',
      ),
    ];

    final navProvider = context.watch<NavigationProvider>();
    final voiceController = context.watch<VoiceCommandController>();

    // Initialize FAB position if not set
    if (_fabPosition.dx == -1) {
      final size = MediaQuery.of(context).size;
      _fabPosition = Offset(size.width - 90, size.height - 180);
    }

    Widget mainScaffold = Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: CustomAppBar(
        onMenuTap: _toggleMenu,
        statusKey: _statusKey,
        batteryKey: _batteryKey,
        menuKey: _menuKey,
      ),
      body: Stack(
        children: [
          // Content based on Index
          _buildBodyContent(navProvider.currentTabIndex),

          // Transparent barrier when menu is open
          if (_isMenuVisible)
            GestureDetector(
              onTap: _toggleMenu,
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),

          // Floating Menu Overlay
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

          // Draggable/Swipeable Mic Button
          Positioned(
            left: _fabPosition.dx,
            top: _fabPosition.dy,
            child: Draggable(
              feedback: _buildMicButton(voiceController, isFeedback: true),
              childWhenDragging: const SizedBox.shrink(),
              onDragEnd: (details) {
                setState(() {
                  // Docking logic: if swiped very close to right edge, hide/minimize
                  final screenWidth = MediaQuery.of(context).size.width;
                  if (details.offset.dx > screenWidth - 60) {
                    _fabPosition = Offset(screenWidth - 30, details.offset.dy);
                  } else if (details.offset.dx < 10) {
                    _fabPosition = Offset(-30, details.offset.dy);
                  } else {
                    _fabPosition = details.offset;
                  }
                });
              },
              child: _buildMicButton(voiceController),
            ),
          ),

          // Global Processing Overlay
          if (voiceController.isProcessing)
            Positioned.fill(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.white, strokeWidth: 5),
                          const SizedBox(height: 20),
                          Text(
                            "EasyLens is thinking...",
                            style: TextStyle(
                              fontFamily: 'HeaderFont',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Navigation bar
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomNavBar(
              currentIndex: navProvider.currentTabIndex,
              onTap: (index) => navProvider.setTabIndex(index),
              homeKey: _homeTabKey,
              navKey: _navTabKey,
              devicesKey: _devicesTabKey,
            ),
          ),
        ],
      ),
    );

    // ... (walkthrough logic)
    return mainScaffold;
  }

  Widget _buildMicButton(VoiceCommandController controller, {bool isFeedback = false}) {
    final bool isListening = controller.isListening;
    final bool isDocked = _fabPosition.dx > MediaQuery.of(context).size.width - 40 || _fabPosition.dx < 0;

    return GestureDetector(
      onTap: isDocked ? () {
        setState(() {
          final screenWidth = MediaQuery.of(context).size.width;
          _fabPosition = Offset(_fabPosition.dx < 0 ? 20 : screenWidth - 90, _fabPosition.dy);
        });
      } : () => controller.toggleListening(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isDocked ? 40 : 72,
        height: 72,
        decoration: BoxDecoration(
          color: isListening ? Colors.red : const Color(0xFF08209A),
          borderRadius: BorderRadius.circular(isDocked ? 10 : 36),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
          ],
        ),
        child: Icon(
          isDocked ? ( _fabPosition.dx < 0 ? Icons.chevron_right : Icons.chevron_left) 
                   : (isListening ? Icons.stop : Icons.mic),
          size: isDocked ? 24 : 34,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBodyContent(int index) {
    switch (index) {
      case 0:
        return _buildHomeDashboard();
      case 1:
        return const NavigationView();
      case 2:
        return const DevicesView();
      case 3:
        return const ChatScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHomeDashboard() {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF08209A)));
    }

    // Check permissions as the phone camera is the primary/backup 'eyes'
    if (!_isPermissionGranted) {
      return _buildPermissionDeniedCard();
    }
    
    return _buildMainDashboard();
  }

  Widget _buildMainDashboard() {
    final settings = context.watch<SettingsProvider>();
    final isConnected = _isTutorialConnectedMock || settings.isBleConnected;
    
    return ScanningDashboardView(
      glassesCardKey: _glassesCardKey,
      glassesImageKey: _glassesImageKey,
      scanningCardKey: _scanningCardKey,
      statsRowKey: _statsRowKey,
      geminiButtonKey: _geminiButtonKey,
      isConnected: isConnected,
      cameraFeed: _buildCameraFeed(),
      cameraController: _cameraController,
    );
  }

  Widget _buildPermissionDeniedCard() {
    return SpotlightTarget(
      id: 'camera_placeholder',
      child: Center(
        key: _cameraPlaceholderKey,
        child: Container(
          width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Large Blue Camera Icon - Exactly as mocked
            Image.asset(
              'assets/icons/object-icon/camera.png',
              width: 160,
              height: 160,
              color: const Color(0xFF08209A),
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 60),
            const Text(
              'Enable camera\npermissions in your\ndevice settings to view\nthe live feed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'HeaderFont',
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ],
        ),
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
      ],
    );
  }
}
