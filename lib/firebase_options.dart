// lib/firebase_options.dart
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importa flutter_dotenv

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web {
    final apiKey = dotenv.env['FIREBASE_WEB_API_KEY'];
    final appId = dotenv.env['FIREBASE_WEB_APP_ID'];
    final messagingSenderId = dotenv.env['FIREBASE_WEB_MESSAGING_SENDER_ID'];
    final projectId = dotenv.env['FIREBASE_WEB_PROJECT_ID'];
    final authDomain = dotenv.env['FIREBASE_WEB_AUTH_DOMAIN'];
    final databaseURL = dotenv.env['FIREBASE_WEB_DATABASE_URL'];
    final storageBucket = dotenv.env['FIREBASE_WEB_STORAGE_BUCKET'];
    final measurementId = dotenv.env['FIREBASE_WEB_MEASUREMENT_ID'];

    if (apiKey == null ||
        appId == null ||
        messagingSenderId == null ||
        projectId == null ||
        authDomain == null ||
        databaseURL == null ||
        storageBucket == null ||
        measurementId == null) {
      throw Exception('Mancano alcune variabili Firebase Web nel file .env');
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain,
      databaseURL: databaseURL,
      storageBucket: storageBucket,
      measurementId: measurementId,
    );
  }

  static FirebaseOptions get android {
    final apiKey = dotenv.env['FIREBASE_ANDROID_API_KEY'];
    final appId = dotenv.env['FIREBASE_ANDROID_APP_ID'];
    final messagingSenderId = dotenv.env['FIREBASE_ANDROID_MESSAGING_SENDER_ID'];
    final projectId = dotenv.env['FIREBASE_ANDROID_PROJECT_ID'];
    final databaseURL = dotenv.env['FIREBASE_ANDROID_DATABASE_URL'];
    final storageBucket = dotenv.env['FIREBASE_ANDROID_STORAGE_BUCKET'];

    if (apiKey == null ||
        appId == null ||
        messagingSenderId == null ||
        projectId == null ||
        databaseURL == null ||
        storageBucket == null) {
      throw Exception('Mancano alcune variabili Firebase Android nel file .env');
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      databaseURL: databaseURL,
      storageBucket: storageBucket,
    );
  }

  static FirebaseOptions get ios {
    final apiKey = dotenv.env['FIREBASE_IOS_API_KEY'];
    final appId = dotenv.env['FIREBASE_IOS_APP_ID'];
    final messagingSenderId = dotenv.env['FIREBASE_IOS_MESSAGING_SENDER_ID'];
    final projectId = dotenv.env['FIREBASE_IOS_PROJECT_ID'];
    final databaseURL = dotenv.env['FIREBASE_IOS_DATABASE_URL'];
    final storageBucket = dotenv.env['FIREBASE_IOS_STORAGE_BUCKET'];
    final iosBundleId = dotenv.env['FIREBASE_IOS_BUNDLE_ID'];

    if (apiKey == null ||
        appId == null ||
        messagingSenderId == null ||
        projectId == null ||
        databaseURL == null ||
        storageBucket == null ||
        iosBundleId == null) {
      throw Exception('Mancano alcune variabili Firebase iOS nel file .env');
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      databaseURL: databaseURL,
      storageBucket: storageBucket,
      iosBundleId: iosBundleId,
    );
  }
}
