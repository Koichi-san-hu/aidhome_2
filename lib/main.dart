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
import 'package:progetti/screens/instructions_page.dart'; // Ensure all pages are imported
import 'package:progetti/screens/cooking_page.dart'; // Importa la nuova pagina se necessario
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carica le variabili d'ambiente dal file .env
  try {
    await dotenv.load(fileName: ".env");
    print("File .env caricato correttamente.");
  } catch (e) {
    print("Errore nel caricare il file .env: $e");
    // Termina l'applicazione se .env non è caricato
    // Flutter non supporta 'exit', quindi lancia un'eccezione
    throw Exception('File .env non trovato. L\'app verrà terminata.');
  }

  // Inizializza Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase inizializzato correttamente.");

  // Inizializza Hive
  await Hive.initFlutter();
  print("Hive inizializzato correttamente.");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthService authService = AuthService();

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
              checkAndUpdateData(context); // Assicurati che l'aggiornamento avvenga qui
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

  Future<void> checkAndUpdateData(BuildContext context) async {
    Box box = await Hive.openBox('consigliBox');
    final lastUpdate = box.get('lastUpdate', defaultValue: 0);
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    const unaSettimanaInMillisecondi = 7 * 24 * 60 * 60 * 1000; // 7 giorni
    const cinqueSecondiInMillisecondi = 5 * 1000; // 5 secondi
    // Stampa il tempo dell'ultimo aggiornamento e il tempo corrente per il controllo
    print("Ultimo aggiornamento: $lastUpdate");
    print("Tempo corrente: $currentTime");

    if (currentTime - lastUpdate > cinqueSecondiInMillisecondi) {
      print("È necessario aggiornare i dati.");
      await updateAndCacheData(box);
      print("Dati aggiornati correttamente.");
    } else {
      print("Non è necessario aggiornare i dati.");
    }
  }

  Future<void> updateAndCacheData(Box box) async {
    final firestore = FirebaseFirestore.instance;

    // Recupera i dati dalla collectionGroup 'Luoghi'
    final meteoConditionsSnapshot = await firestore.collectionGroup('Luoghi').get();

    print("Inizio del recupero dei dati da Firestore e memorizzazione in Hive.");

    for (var document in meteoConditionsSnapshot.docs) {
      try {
        String hiveKey = document.reference.path;
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        // Converti DocumentReference in stringa prima di salvare in Hive
        data = data.map((key, value) {
          if (value is DocumentReference) {
            return MapEntry(key, value.path); // salva solo il percorso del DocumentReference come stringa
          }
          return MapEntry(key, value);
        });

        print("Salvataggio in Hive -> Chiave: $hiveKey, Dati: $data");

        // Salva i dati nel box di Hive
        await box.put(hiveKey, data);
      } catch (e) {
        print('Errore durante il salvataggio del documento $document: $e');
        continue; // Continua con il prossimo documento in caso di errore
      }
    }

    // Recupera gli Ingredienti dal percorso specificato
    try {
      DocumentReference ingredientiDocRef = firestore
          .collection('Consigli')
          .doc('Cucina')
          .collection('Ingredienti')
          .doc('EHABmvH4b5Wb65GFMkVz');

      DocumentSnapshot ingredientiSnapshot = await ingredientiDocRef.get();

      if (ingredientiSnapshot.exists) {
        Map<String, dynamic>? ingredientiData = ingredientiSnapshot.data() as Map<String, dynamic>?;

        if (ingredientiData != null && ingredientiData.containsKey('Ingredienti')) {
          List<dynamic> ingredientiListDynamic = ingredientiData['Ingredienti'];
          List<String> ingredientiList = ingredientiListDynamic.map((e) => e.toString()).toList();

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

    final newLastUpdate = DateTime.now().millisecondsSinceEpoch;
    await box.put('lastUpdate', newLastUpdate);

    print("Aggiornamento completato. Nuovo timestamp dell'ultimo aggiornamento: $newLastUpdate");
  }
}
