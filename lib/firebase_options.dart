// lib/firebase_options.dart
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importo flutter_dotenv per leggere le variabili d'ambiente dal file .env

// Classe che contiene le opzioni di configurazione Firebase specifiche per ogni piattaforma
class DefaultFirebaseOptions {

  // Recupero le opzioni Firebase appropriate per la piattaforma corrente
  static FirebaseOptions get currentPlatform {
    // Se sto eseguendo il progetto su web, ritorno la configurazione specifica per il Web
    if (kIsWeb) {
      return web;
    }

    // Se non sono su Web, utilizzo lo switch per identificare la piattaforma corrente
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android; // Configurazione Firebase per Android
      case TargetPlatform.iOS:
        return ios; // Configurazione Firebase per iOS
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Le opzioni Firebase per macOS non sono state configurate. '
              'Puoi configurarle nuovamente utilizzando il FlutterFire CLI.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Le opzioni Firebase per Windows non sono state configurate. '
              'Puoi configurarle nuovamente utilizzando il FlutterFire CLI.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Le opzioni Firebase per Linux non sono state configurate. '
              'Puoi configurarle nuovamente utilizzando il FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'Le opzioni Firebase non sono supportate per questa piattaforma.',
        );
    }
  }

  // Configurazione per Firebase Web
  static FirebaseOptions get web {
    // Recupero le variabili d'ambiente definite nel file .env
    final apiKey = dotenv.env['FIREBASE_WEB_API_KEY'];
    final appId = dotenv.env['FIREBASE_WEB_APP_ID'];
    final messagingSenderId = dotenv.env['FIREBASE_WEB_MESSAGING_SENDER_ID'];
    final projectId = dotenv.env['FIREBASE_WEB_PROJECT_ID'];
    final authDomain = dotenv.env['FIREBASE_WEB_AUTH_DOMAIN'];
    final databaseURL = dotenv.env['FIREBASE_WEB_DATABASE_URL'];
    final storageBucket = dotenv.env['FIREBASE_WEB_STORAGE_BUCKET'];
    final measurementId = dotenv.env['FIREBASE_WEB_MEASUREMENT_ID'];

    // Se manca qualche variabile obbligatoria, lancio un'eccezione per segnalare il problema
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

    // Ritorno le opzioni configurate per Firebase Web
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

  // Configurazione per Firebase Android
  static FirebaseOptions get android {
    // Recupero le variabili d'ambiente definite nel file .env
    final apiKey = dotenv.env['FIREBASE_ANDROID_API_KEY'];
    final appId = dotenv.env['FIREBASE_ANDROID_APP_ID'];
    final messagingSenderId = dotenv.env['FIREBASE_ANDROID_MESSAGING_SENDER_ID'];
    final projectId = dotenv.env['FIREBASE_ANDROID_PROJECT_ID'];
    final databaseURL = dotenv.env['FIREBASE_ANDROID_DATABASE_URL'];
    final storageBucket = dotenv.env['FIREBASE_ANDROID_STORAGE_BUCKET'];

    // Se manca qualche variabile obbligatoria, lancio un'eccezione per segnalare il problema
    if (apiKey == null ||
        appId == null ||
        messagingSenderId == null ||
        projectId == null ||
        databaseURL == null ||
        storageBucket == null) {
      throw Exception('Mancano alcune variabili Firebase Android nel file .env');
    }

    // Ritorno le opzioni configurate per Firebase Android
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      databaseURL: databaseURL,
      storageBucket: storageBucket,
    );
  }

  // Configurazione per Firebase iOS
  static FirebaseOptions get ios {
    // Recupero le variabili d'ambiente definite nel file .env
    final apiKey = dotenv.env['FIREBASE_IOS_API_KEY'];
    final appId = dotenv.env['FIREBASE_IOS_APP_ID'];
    final messagingSenderId = dotenv.env['FIREBASE_IOS_MESSAGING_SENDER_ID'];
    final projectId = dotenv.env['FIREBASE_IOS_PROJECT_ID'];
    final databaseURL = dotenv.env['FIREBASE_IOS_DATABASE_URL'];
    final storageBucket = dotenv.env['FIREBASE_IOS_STORAGE_BUCKET'];
    final iosBundleId = dotenv.env['FIREBASE_IOS_BUNDLE_ID'];

    // Se manca qualche variabile obbligatoria, lancio un'eccezione per segnalare il problema
    if (apiKey == null ||
        appId == null ||
        messagingSenderId == null ||
        projectId == null ||
        databaseURL == null ||
        storageBucket == null ||
        iosBundleId == null) {
      throw Exception('Mancano alcune variabili Firebase iOS nel file .env');
    }

    // Ritorno le opzioni configurate per Firebase iOS
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
