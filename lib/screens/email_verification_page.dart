import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:progetti/screens/home_screen.dart';
import 'package:progetti/screens/auth_page.dart';
/*
  EmailVerificationPage - Pagina di Verifica Email per l'app Flutter

  Questa pagina è progettata per gestire il processo di verifica dell'email degli utenti nell'app.
  Fornisce un'interfaccia semplice per guidare l'utente attraverso il processo di verifica dell'email
  dopo la registrazione.

  Caratteristiche principali:
  - Monitoraggio dello stato di verifica dell'email: La pagina controlla periodicamente (ogni 3 secondi)
    se l'utente ha verificato la propria email.
  - Reindirizzamento automatico: Una volta che l'email è stata verificata, l'utente viene automaticamente
    reindirizzato alla `PrimaPagina` dell'app.
  - Opzione per ritornare alla pagina di autenticazione: Se l'utente necessita di tornare alla schermata di
    login, può farlo facilmente tramite un link interattivo.

  Utilizzo:
  - Gli utenti vengono diretti a questa pagina dopo essersi registrati, dove devono verificare la loro email
    prima di procedere a utilizzare l'app.
  - La pagina fornisce feedback immediato e istruzioni su come completare il processo di verifica.

  Implementazione:
  - La classe è uno StatefulWidget per gestire il monitoraggio dello stato di verifica dell'email.
  - Utilizza Firebase Authentication per accertarsi dello stato di verifica dell'email dell'utente.

  Autore: Fabio Koichi Begnini

*/

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _auth.currentUser!.reload();
      if (_auth.currentUser!.emailVerified) {
        timer.cancel();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PrimaPagina()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conferma Email')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Accedi alla tua email e conferma la registrazione.'),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Ho confermato, Accedi'),
              onPressed: () async {
                await _auth.currentUser!.reload();
                if (_auth.currentUser!.emailVerified) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PrimaPagina()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Per favore, conferma prima la tua email.')));
                }
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // Reindirizzo l'utente alla pagina di autenticazione
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthPage()));
              },
              child: const Text(
                'Torna alla pagina di accesso',
                style: TextStyle(
                  color: Colors.blue, // Puoi scegliere qualsiasi colore
                  decoration: TextDecoration.underline, // Sottolinea il testo per far capire che è cliccabile
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
