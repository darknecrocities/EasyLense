import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easylense_prototype/main.dart';
import 'package:easylense_prototype/screens/onboarding/welcome_screen.dart';
import 'firebase_mock.dart';

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({'stay_logged_in': false});
  });

  testWidgets('EasyLensApp loads, triggers AuthWrapper, and navigates to WelcomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const EasyLensApp());
    expect(find.byType(EasyLensApp), findsOneWidget);
    
    // Initially showing CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the SharedPreferences future resolve and stream yield unauthenticated state
    await tester.pump();
    
    // Allow the transition to the new screen
    await tester.pump(const Duration(milliseconds: 500));

    // WelcomeScreen should be shown since there is no logged-in user
    expect(find.byType(WelcomeScreen), findsOneWidget);

    // Let the timers in WelcomeScreen finish to avoid "pending timer" error
    await tester.pump(const Duration(seconds: 5));
  });
}
