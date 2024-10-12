// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:progetti/services/auth_service.dart';
import 'package:progetti/screens/auth_page.dart';
import 'package:progetti/screens/email_verification_page.dart';
import 'package:progetti/screens/home_screen.dart';
import 'package:progetti/screens/instructions_page.dart';
import 'package:progetti/screens/cooking_page.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; // Importa il pacchetto per i permessi

// Istanza globale del plugin delle notifiche
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carico le variabili d'ambiente dal file .env
  try {
    await dotenv.load(fileName: ".env");
    print("File .env caricato correttamente.");
  } catch (e) {
    print("Errore nel caricare il file .env: $e");
    throw Exception('File .env non trovato. L\'app verrà terminata.');
  }

  // Inizializzo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase inizializzato correttamente.");

  // Inizializzo Hive
  await Hive.initFlutter();
  print("Hive inizializzato correttamente.");

  // Richiedi i permessi per le notifiche
  await requestNotificationPermission();

  // Inizializzo le notifiche
  await initNotifications();

  runApp(MyApp());
}

// Richiede il permesso per le notifiche su entrambe le piattaforme
Future<void> requestNotificationPermission() async {
  // Per Android (utilizzando permission_handler)
  if (await Permission.notification.isDenied ||
      await Permission.notification.isPermanentlyDenied) {
    PermissionStatus status = await Permission.notification.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      print('Permesso per le notifiche negato su Android');
    } else {
      print('Permesso per le notifiche concesso su Android');
    }
  }

  // Per iOS
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    scheduleHourlyNotification();
  }

  void scheduleHourlyNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'canale_notifiche',
      'Notifiche Orarie',
      channelDescription: 'Questo canale è per le notifiche orarie',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      'AidHome',
      'Ciao, è ora di tornare nell\'app!',
      RepeatInterval.hourly,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AidHome 2.0',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('it', 'IT')],
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          color: Colors.lightBlue,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.greenAccent,
        ),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            backgroundColor: Colors.orange,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFE0F7FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.lightBlue, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData && snapshot.data!.emailVerified) {
              checkAndUpdateData(context);
              return const PrimaPagina();
            } else if (snapshot.hasData) {
              return const EmailVerificationPage();
            } else {
              return const AuthPage();
            }
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  // Verifica se i dati devono essere aggiornati e aggiorna se necessario
  Future<void> checkAndUpdateData(BuildContext context) async {
    Box box =
    await Hive.openBox('consigliBox'); // Apre il box di Hive 'consigliBox'
    final lastUpdate =
    box.get('lastUpdate', defaultValue: 0); // Ottiene il timestamp dell'ultimo aggiornamento
    final currentTime =
        DateTime.now().millisecondsSinceEpoch; // Ottiene il timestamp attuale
    const unaSettimanaInMillisecondi = 7 * 24 * 60 * 60 * 1000; // Millisecondi in una settimana

    // Stampa di debug per controllare gli orari
    print("Ultimo aggiornamento: $lastUpdate");
    print("Tempo corrente: $currentTime");

    if (currentTime - lastUpdate > unaSettimanaInMillisecondi) {
      print("È necessario aggiornare i dati."); // Debug: richiede aggiornamento
      await updateAndCacheData(box); // Aggiorna i dati e li memorizza in cache
      print("Dati aggiornati correttamente.");
    } else {
      print("Non è necessario aggiornare i dati."); // Debug: aggiornamento non necessario
    }
  }

  // Recupera e memorizza i dati da Firestore in Hive
  Future<void> updateAndCacheData(Box box) async {
    final firestore = FirebaseFirestore.instance;

    // Recupera tutti i documenti dalla collectionGroup 'Luoghi'
    final meteoConditionsSnapshot =
    await firestore.collectionGroup('Luoghi').get();
    print("Inizio del recupero dei dati da Firestore e memorizzazione in Hive.");

    for (var document in meteoConditionsSnapshot.docs) {
      try {
        String hiveKey =
            document.reference.path; // Chiave di Hive basata sul percorso del documento
        Map<String, dynamic> data = document.data();

        // Converti DocumentReference in stringa prima di salvare in Hive
        data = data.map((key, value) {
          if (value is DocumentReference) {
            return MapEntry(key, value.path); // Memorizza solo il percorso del DocumentReference
          }
          return MapEntry(key, value);
        });

        print("Salvataggio in Hive -> Chiave: $hiveKey, Dati: $data");

        // Salva i dati nel box di Hive
        await box.put(hiveKey, data);
      } catch (e) {
        print('Errore durante il salvataggio del documento $document: $e');
        continue;
      }
    }

    // Recupera gli ingredienti dalla collezione specificata
    try {
      DocumentReference ingredientiDocRef = firestore
          .collection('Consigli')
          .doc('Cucina')
          .collection('Ingredienti')
          .doc('EHABmvH4b5Wb65GFMkVz');

      DocumentSnapshot ingredientiSnapshot = await ingredientiDocRef.get();

      if (ingredientiSnapshot.exists) {
        Map<String, dynamic>? ingredientiData =
        ingredientiSnapshot.data() as Map<String, dynamic>?;

        if (ingredientiData != null &&
            ingredientiData.containsKey('Ingredienti')) {
          List<dynamic> ingredientiListDynamic = ingredientiData['Ingredienti'];
          List<String> ingredientiList =
          ingredientiListDynamic.map((e) => e.toString()).toList();

          print("Salvataggio degli ingredienti in Hive: $ingredientiList");

          // Salva gli ingredienti nel box di Hive sotto la chiave 'cucinaIngredienti'
          await box.put('cucinaIngredienti', ingredientiList);
        } else {
          print("Campo 'Ingredienti' non trovato nel documento.");
        }
      } else {
        print("Documento degli Ingredienti non esiste.");
      }
    } catch (e) {
      print('Errore durante il recupero degli Ingredienti: $e');
    }

    final newLastUpdate =
        DateTime.now().millisecondsSinceEpoch; // Nuovo timestamp dell'ultimo aggiornamento
    await box.put('lastUpdate', newLastUpdate); // Memorizza il timestamp dell'aggiornamento

    print(
        "Aggiornamento completato. Nuovo timestamp dell'ultimo aggiornamento: $newLastUpdate");
  }
}
