import 'package:flutter/material.dart';
import 'package:progetti/services/auth_service.dart';
import 'package:progetti/screens/auth_page.dart';
import 'package:progetti/models/user.dart'; // Assicurati di importare UserData
import 'package:progetti/screens/profile_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String userName = 'Non disponibile';
  String userKey = 'Non disponibile';
  String userEmail = 'Non disponibile';
  String userMaxUsageApp = 'Non disponibile';
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    var userData = await UserData.getUserData(); // Utilizza UserData per ottenere i dati
    if (userData != null) {
      setState(() {
        userName = userData.nome;
        userKey = userData.chiaveRiconoscimento;
        userEmail = userData.email;
        userMaxUsageApp= userData.MaxUsageApp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.teal,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Menu', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    const Icon(Icons.account_circle, size: 50),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          userName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          userKey,
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const ListTile(
            leading: Icon(Icons.settings),
            title: Text('Impostazioni'),
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
            title: Text('Invita un amico'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Mostriamo un dialogo di conferma
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
                          Navigator.of(context).pop(); // Chiude il dialogo
                        },
                      ),
                      TextButton(
                        child: const Text('Logout'),
                        onPressed: () async {
                          UserData.clearCache(); // Pulisce la cache dei dati utente PRIMA del logout
                          await authService.signOut(); // Esegue il logout da Firebase
                          Navigator.of(context).popUntil((route) => route.isFirst); // Chiude il dialogo e tutti i widget sovrastanti fino alla prima pagina
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthPage()));
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
