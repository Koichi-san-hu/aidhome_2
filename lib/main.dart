// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
// Ho aggiunto l'import di questa pagina
// Ho aggiunto l'import della nuova pagina per la sezione di cucina
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Assicura che i widget siano inizializzati correttamente prima di eseguire altro codice

  // Carico le variabili d'ambiente dal file .env
  try {
    await dotenv.load(fileName: ".env"); // Tenta di caricare il file .env contenente le variabili
    if (kDebugMode) {
      print("File .env caricato correttamente.");
    } // Debug: conferma il caricamento
  } catch (e) {
    if (kDebugMode) {
      print("Errore nel caricare il file .env: $e");
    } // Debug: indica un errore nel caricamento del file .env
    // Flutter non supporta la funzione 'exit', quindi devo gestire l'errore lanciando un'eccezione
    throw Exception('File .env non trovato. L\'app verrà terminata.');
  }

  // Inizializzo Firebase con le opzioni specifiche della piattaforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    print("Firebase inizializzato correttamente.");
  } // Debug: conferma l'inizializzazione di Firebase

  // Inizializzo Hive per la gestione della cache
  await Hive.initFlutter();
  if (kDebugMode) {
    print("Hive inizializzato correttamente.");
  } // Debug: conferma l'inizializzazione di Hive

  runApp(MyApp()); // Avvio l'applicazione con la classe MyApp
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthService authService = AuthService(); // Istanzio il servizio di autenticazione

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AidHome 2.0', // Nome dell'applicazione
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('it', 'IT')], // Lingua supportata: Italiano
      theme: ThemeData(
        primarySwatch: Colors.brown, // Colore principale
        fontFamily: 'Roboto', // Font predefinito
        appBarTheme: const AppBarTheme(
          color: Colors.lightBlue, // Colore della barra superiore
          iconTheme: IconThemeData(color: Colors.white), // Colore delle icone nella barra superiore
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.greenAccent, // Colore dei bottoni flottanti
        ),
        scaffoldBackgroundColor: Colors.white, // Colore di sfondo degli scaffold
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)), // Bottone con bordi arrotondati
            ),
            backgroundColor: Colors.orange, // Colore dei bottoni
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFE0F7FA), // Colore di sfondo dei campi di input
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)), // Bordi dei campi di input arrotondati
            borderSide: BorderSide.none, // Nessun bordo per i campi di input
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.lightBlue, width: 2), // Bordo per i campi attivi
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue, width: 2), // Bordo per i campi in focus
          ),
        ),
        useMaterial3: true, // Uso del Material Design 3
      ),
      home: StreamBuilder<User?>(
        stream: authService.authStateChanges, // Ascolta i cambiamenti dello stato di autenticazione
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) { // Controlla se la connessione è attiva
            if (snapshot.hasData && snapshot.data!.emailVerified) { // Utente autenticato e con email verificata
              checkAndUpdateData(context); // Verifica e aggiorna i dati
              return const PrimaPagina(); // Naviga alla pagina principale
            } else if (snapshot.hasData) {
              return const EmailVerificationPage(); // Utente autenticato ma email non verificata
            } else {
              return const AuthPage(); // Utente non autenticato, mostra la pagina di login
            }
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // Mostra un indicatore di caricamento
          );
        },
      ),
    );
  }

  // Verifica se i dati devono essere aggiornati e aggiorna se necessario
  Future<void> checkAndUpdateData(BuildContext context) async {
    Box box = await Hive.openBox('consigliBox'); // Apre il box di Hive 'consigliBox'
    final lastUpdate = box.get('lastUpdate', defaultValue: 0); // Ottiene il timestamp dell'ultimo aggiornamento
    final currentTime = DateTime.now().millisecondsSinceEpoch; // Ottiene il timestamp attuale
    const unaSettimanaInMillisecondi = 7 * 24 * 60 * 60 * 1000; // Millisecondi in una settimana (non usato)
    const cinqueSecondiInMillisecondi = 5 * 1000; // 5 secondi in millisecondi (usato per debug)

    // Stampa di debug per controllare gli orari
    if (kDebugMode) {
      print("Ultimo aggiornamento: $lastUpdate");
    }
    if (kDebugMode) {
      print("Tempo corrente: $currentTime");
    }

    if (currentTime - lastUpdate > cinqueSecondiInMillisecondi) { // Se è passato più di 5 secondi dall'ultimo update
      if (kDebugMode) {
        print("È necessario aggiornare i dati.");
      } // Debug: richiede aggiornamento
      await updateAndCacheData(box); // Aggiorna i dati e li memorizza in cache
      if (kDebugMode) {
        print("Dati aggiornati correttamente.");
      }
    } else {
      if (kDebugMode) {
        print("Non è necessario aggiornare i dati.");
      } // Debug: aggiornamento non necessario
    }
  }

  // Recupera e memorizza i dati da Firestore in Hive
  Future<void> updateAndCacheData(Box box) async {
    final firestore = FirebaseFirestore.instance;

    // Recupera tutti i documenti dalla collectionGroup 'Luoghi'
    final meteoConditionsSnapshot = await firestore.collectionGroup('Luoghi').get();
    if (kDebugMode) {
      print("Inizio del recupero dei dati da Firestore e memorizzazione in Hive.");
    }

    for (var document in meteoConditionsSnapshot.docs) {
      try {
        String hiveKey = document.reference.path; // Chiave di Hive basata sul percorso del documento
        Map<String, dynamic> data = document.data();

        // Converti DocumentReference in stringa prima di salvare in Hive
        data = data.map((key, value) {
          if (value is DocumentReference) {
            return MapEntry(key, value.path); // Memorizza solo il percorso del DocumentReference
          }
          return MapEntry(key, value);
        });

        if (kDebugMode) {
          print("Salvataggio in Hive -> Chiave: $hiveKey, Dati: $data");
        }

        // Salva i dati nel box di Hive
        await box.put(hiveKey, data);
      } catch (e) {
        if (kDebugMode) {
          print('Errore durante il salvataggio del documento $document: $e');
        } // Debug: errore durante il salvataggio
        continue; // Continua con il prossimo documento in caso di errore
      }
    }

    // Recupera gli ingredienti dalla collezione specificata
    try {
      DocumentReference ingredientiDocRef = firestore
          .collection('Consigli')
          .doc('Cucina')
          .collection('Ingredienti')
          .doc('EHABmvH4b5Wb65GFMkVz'); // Percorso del documento

      DocumentSnapshot ingredientiSnapshot = await ingredientiDocRef.get();

      if (ingredientiSnapshot.exists) {
        Map<String, dynamic>? ingredientiData = ingredientiSnapshot.data() as Map<String, dynamic>?;

        if (ingredientiData != null && ingredientiData.containsKey('Ingredienti')) {
          List<dynamic> ingredientiListDynamic = ingredientiData['Ingredienti'];
          List<String> ingredientiList = ingredientiListDynamic.map((e) => e.toString()).toList();

          if (kDebugMode) {
            print("Salvataggio degli ingredienti in Hive: $ingredientiList");
          }

          // Salva gli ingredienti nel box di Hive sotto la chiave 'cucinaIngredienti'
          await box.put('cucinaIngredienti', ingredientiList);
        } else {
          if (kDebugMode) {
            print("Campo 'Ingredienti' non trovato nel documento.");
          } // Debug: errore nel documento
        }
      } else {
        if (kDebugMode) {
          print("Documento degli Ingredienti non esiste.");
        } // Debug: documento non trovato
      }
    } catch (e) {
      if (kDebugMode) {
        print('Errore durante il recupero degli Ingredienti: $e');
      } // Debug: errore durante il recupero degli ingredienti
    }

    final newLastUpdate = DateTime.now().millisecondsSinceEpoch; // Nuovo timestamp dell'ultimo aggiornamento
    await box.put('lastUpdate', newLastUpdate); // Memorizza il timestamp dell'aggiornamento

    if (kDebugMode) {
      print("Aggiornamento completato. Nuovo timestamp dell'ultimo aggiornamento: $newLastUpdate");
    }
  }
}
