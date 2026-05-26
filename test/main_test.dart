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

  group('EasyLensApp & AuthWrapper Tests', () {
    testWidgets('EasyLensApp builds and provides correct theme', (WidgetTester tester) async {
      await tester.pumpWidget(const EasyLensApp());
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, 'EasyLens');
      expect(materialApp.debugShowCheckedModeBanner, false);
      expect(materialApp.theme?.brightness, Brightness.dark); // AppTheme.darkTheme
      
      // Let any timers clean up
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('AuthWrapper initially shows loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthWrapper()));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Let any timers clean up
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('AuthWrapper navigates to WelcomeScreen on unauthenticated state', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthWrapper()));
      
      // Initially showing CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let SharedPreferences resolve and the StreamBuilder yield the auth state
      await tester.pump();
      
      // WelcomeScreen should be shown (since our mock returns no user)
      expect(find.byType(WelcomeScreen), findsOneWidget);

      // Let WelcomeScreen timers clean up
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
