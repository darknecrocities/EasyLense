import 'package:flutter/material.dart';
import 'package:easylense_prototype/screens/auth_gateway_screen.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _introData = [
    {
      'title': 'Real-Time Detection',
      'description': 'Instantly identify obstacles, stairs, and approaching vehicles in your path using on-device AI.',
      'icon': 'assets/images/introduction_icons/person_wifi.png',
    },
    {
      'title': 'Clear Voice Guidance',
      'description': 'Hear your surroundings instantly. Get natural, fast voice alerts in your choice of English or Filipino.',
      'icon': 'assets/images/introduction_icons/person_speaker.png',
    },
    {
      'title': 'Smart Haptic Alerts',
      'description': 'Feel your environment. EasyLens uses distinct vibration patterns to warn you of sudden hazards or emergencies.',
      'icon': 'assets/images/introduction_icons/person_haptic.png',
    },
    {
      'title': '100% Private & Secure',
      'description': 'Your safety is private. All camera processing happens directly on your device. No data is ever sent to the cloud.',
      'icon': 'assets/images/introduction_icons/person_lock.png',
    },
  ];

  void _skip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGatewayScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _introData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _skip();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with SKIP
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _skip,
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        fontFamily: 'HeaderFont',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Content (PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _introData.length,
                itemBuilder: (context, index) {
                  final data = _introData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon image
                        Image.asset(
                          data['icon']!,
                          width: 250,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 40),
                        
                        // Title
                        Text(
                          data['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'HeaderFont',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Description
                        Text(
                          data['description']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'DescriptionFont',
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: 260,
                height: 46,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF08209A), // Requested blue color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _introData.length - 1 ? 'GET STARTED' : 'NEXT',
                    style: const TextStyle(
                      fontFamily: 'HeaderFont',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
