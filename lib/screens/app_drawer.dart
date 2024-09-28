import 'package:flutter/material.dart';
import 'package:progetti/screens/profile_screen.dart';
import 'package:progetti/services/UserData.dart'; // Assicuro che il servizio UserData sia importato

import '../services/auth_service.dart';
import 'auth_page.dart';

// Drawer (menu laterale) personalizzato
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // Variabili che memorizzano i dati utente. Inizialmente impostate su 'Non disponibile'.
  String userName = 'Non disponibile';
  String userKey = 'Non disponibile';
  String userEmail = 'Non disponibile';
  String userMaxUsageApp = 'Non disponibile';

  @override
  void initState() {
    super.initState();
    // Recupero i dati utente all'inizializzazione del drawer
    _fetchUserData();
  }

  // Funzione per recuperare i dati dell'utente da UserData
  Future<void> _fetchUserData() async {
    var userData = await UserData.getUserData(); // Chiamata al metodo getUserData()
    if (userData != null) {
      setState(() {
        userName = userData.nome;
        userKey = userData.chiaveRiconoscimento;
        userEmail = userData.email;
        userMaxUsageApp = userData.MaxUsageApp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService(); // Inizializzo il servizio di autenticazione

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.teal, // Imposto il colore del header
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Menu', style: TextStyle(color: Colors.black)),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    const Icon(Icons.account_circle, size: 50), // Icona profilo
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(userName, style: const TextStyle(color: Colors.black)),
                        Text(userKey, style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const ListTile(
            leading: Icon(Icons.settings),
            title: Text('Impostazioni'), // Placeholder per le impostazioni
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts),
            title: const Text('Profilo'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfiloPage())); // Naviga alla pagina del profilo
            },
          ),
          const ListTile(
            leading: Icon(Icons.add_task_sharp),
            title: Text('Invita un amico'), // Placeholder per la funzionalità di invito
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Mostro un dialogo di conferma prima di eseguire il logout
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Conferma'),
                    content: const Text('Sei sicuro di voler uscire?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Annulla'),
                        onPressed: () {
                          Navigator.of(context).pop(); // Chiudo il dialogo senza eseguire azioni
                        },
                      ),
                      TextButton(
                        child: const Text('Logout'),
                        onPressed: () async {
                          UserData.clearCache(); // Pulisco la cache dei dati utente PRIMA del logout
                          await authService.signOut(); // Eseguo il logout da Firebase
                          Navigator.of(context).popUntil((route) => route.isFirst); // Rimuovo tutte le schermate sovrastanti
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthPage())); // Ritorno alla pagina di autenticazione
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
