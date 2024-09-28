import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Classe che rappresenta i dati dell'utente
class UserData {
  final String nome;
  final String cognome;
  final String dataDiNascita;
  final String email;
  final String chiaveRiconoscimento;
  final String MaxUsageApp;

  // Costruttore della classe UserData, che richiede tutti i campi come parametri
  UserData({
    required this.nome,
    required this.cognome,
    required this.dataDiNascita,
    required this.email,
    required this.chiaveRiconoscimento,
    required this.MaxUsageApp,
  });

  // Variabile statica per memorizzare i dati dell'utente nella cache.
  // Mi serve per evitare di recuperare i dati da Firestore ogni volta.
  static UserData? _cachedUserData;

  // Metodo per recuperare i dati dell'utente dalla cache o da Firestore
  static Future<UserData?> getUserData() async {
    // Ottengo l'utente attualmente autenticato tramite FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;

    // Se i dati sono già memorizzati in cache (_cachedUserData non è null), li restituisco direttamente
    if (_cachedUserData != null) {
      return _cachedUserData;
    }

    // Se l'utente è autenticato (non è null), recupero i suoi dati da Firestore
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users') // Collezione 'users' dove sono memorizzati i dati
          .doc(user.uid) // Documento con l'ID utente
          .get(); // Recupero il documento

      // Se il documento esiste, estraggo i dati e li memorizzo nella cache
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        // Inizializzo _cachedUserData con i dati recuperati
        _cachedUserData = UserData(
          nome: data['nome'] ?? 'Non disponibile', // Se il campo 'nome' non esiste, assegno 'Non disponibile'
          cognome: data['cognome'] ?? 'Non disponibile',
          dataDiNascita: data['data_di_nascita'] ?? 'Non disponibile',
          email: data['email'] ?? 'Non disponibile',
          chiaveRiconoscimento: data['chiaveRiconoscimento'] ?? 'Non disponibile',
          MaxUsageApp: data['MaxUsageApp'] ?? 'Non disponibile',
        );

        // Restituisco i dati memorizzati nella cache
        return _cachedUserData;
      }
    }

    // Se l'utente non è autenticato o i dati non sono disponibili, ritorno null
    return null;
  }

  // Metodo per svuotare la cache quando, ad esempio, l'utente esce dall'app o cambia i suoi dati
  static void clearCache() {
    _cachedUserData = null; // Imposto la cache a null per forzare il recupero da Firestore alla prossima richiesta
  }
}
