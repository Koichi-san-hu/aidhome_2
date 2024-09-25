import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:progetti/screens/email_verification_page.dart';
import 'location_service.dart'; // Assicurati di importare la tua classe LocationService
/*
  AuthService - Servizio di Autenticazione per l'app Flutter

  Questa classe incapsula tutte le funzionalità legate all'autenticazione degli utenti tramite Firebase
  Authentication. Gestisce operazioni come il login, la registrazione, il reset della password, la verifica
  dell'email e il logout.

  Caratteristiche principali:
  - Autenticazione: Implementa le funzioni per il login e la registrazione degli utenti utilizzando email e password.
  - Verifica Email: Gestisce la logica per verificare l'email degli utenti appena registrati, reindirizzandoli
    alla pagina di verifica dell'email se necessario.
  - Gestione degli errori: Raccoglie e propaga le eccezioni di FirebaseAuth per consentire una gestione degli
    errori personalizzata nell'interfaccia utente.
  - Reset della Password: Fornisce una funzione per inviare agli utenti un'email per il reset della password.
  - Logout: Permette agli utenti di disconnettersi dall'app.
  - Integrazione con il Servizio di Geolocalizzazione: Dopo un login riuscito, richiede il permesso di
    geolocalizzazione tramite la classe `LocationService`.

  Utilizzo:
  - È utilizzata in varie parti dell'app per gestire l'accesso e la registrazione degli utenti, nonché per
    mantenere e verificare lo stato di autenticazione corrente dell'utente.

  Autore: Fabio Koichi Begnini
*/

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({required String email, required String password,
    required BuildContext context}) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      if (!userCredential.user!.emailVerified) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const EmailVerificationPage()));
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Per favore, verifica la tua email prima di accedere.',
        );
      }
      // Richiamo il metodo per la geolocalizzazione qui
      await LocationService().requestLocationPermission();

    } on FirebaseAuthException catch (e) {
      // Gestisci qui i diversi casi di errore
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw FirebaseAuthException(
          code: e.code,
          message: 'Nome utente o password errati.',
        );
      } else {
        // Propaga l'eccezione se non è uno dei casi gestiti
        rethrow;
      }
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Dopo la creazione dell'account, invia l'email di verifica
    User? user = userCredential.user;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
    return userCredential; // Restituisce il UserCredential
  }


  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification(User user) async {
    await user.sendEmailVerification();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
