import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFirebasePlatform extends FirebasePlatform with MockPlatformInterfaceMixin {
  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseAppPlatform();
  }

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return MockFirebaseAppPlatform();
  }

  @override
  List<FirebaseAppPlatform> get apps => [MockFirebaseAppPlatform()];
}

class MockFirebaseAppPlatform extends FirebaseAppPlatform {
  MockFirebaseAppPlatform() : super(defaultFirebaseAppName, const FirebaseOptions(
    apiKey: 'apiKey',
    appId: 'appId',
    messagingSenderId: 'messagingSenderId',
    projectId: 'projectId',
  ));
}

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebasePlatform.instance = MockFirebasePlatform();
}
