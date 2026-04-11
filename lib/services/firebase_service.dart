import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseService {
  /// Initializes Firebase using runtime variables from the .env file.
  static Future<void> initialize() async {
    // Make sure dotenv is loaded before calling this
    await dotenv.load(fileName: ".env");

    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: kIsWeb 
            ? (dotenv.env['FIREBASE_WEB_API_KEY'] ?? '')
            : (dotenv.env['FIREBASE_API_KEY'] ?? ''),
        appId: kIsWeb 
            ? (dotenv.env['FIREBASE_WEB_APP_ID'] ?? '')
            : (dotenv.env['FIREBASE_APP_ID'] ?? ''),
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
        authDomain: kIsWeb ? dotenv.env['FIREBASE_WEB_AUTH_DOMAIN'] : null,
        measurementId: kIsWeb ? dotenv.env['FIREBASE_WEB_MEASUREMENT_ID'] : null,
      ),
    );
  }
}
