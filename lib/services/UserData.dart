import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String nome;
  final String cognome;
  final String dataDiNascita;
  final String email;
  final String chiaveRiconoscimento;
  final String MaxUsageApp;

  UserData({
    required this.nome,
    required this.cognome,
    required this.dataDiNascita,
    required this.email,
    required this.chiaveRiconoscimento,
    required this.MaxUsageApp,
  });

  // Aggiungo una variabile per memorizzare i dati dell'utente nella cache
  static UserData? _cachedUserData;

  static Future<UserData?> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    // Restituisce i dati dalla cache se già disponibili
    if (_cachedUserData != null) {
      return _cachedUserData;
    }

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        // Salva i dati nella cache prima di restituirli
        _cachedUserData = UserData(
          nome: data['nome'] ?? 'Non disponibile',
          cognome: data['cognome'] ?? 'Non disponibile',
          dataDiNascita: data['data_di_nascita'] ?? 'Non disponibile',
          email: data['email'] ?? 'Non disponibile',
          chiaveRiconoscimento: data['chiaveRiconoscimento'] ?? 'Non disponibile',
          MaxUsageApp: data['MaxUsageApp']?? 'Non disponibile',
        );
        return _cachedUserData;
      }
    }
    return null;
  }

  static void clearCache() {
    _cachedUserData = null;
  }
}
