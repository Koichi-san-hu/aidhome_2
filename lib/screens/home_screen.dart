// lib/screens/prima_pagina.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progetti/screens/weather_screen.dart';
import 'package:progetti/screens/cooking_page.dart'; // Importa CookingPage
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_drawer.dart';

class PrimaPagina extends StatefulWidget {
  const PrimaPagina({super.key});

  @override
  _PrimaPaginaState createState() => _PrimaPaginaState();
}

class _PrimaPaginaState extends State<PrimaPagina> {
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadScore();
  }

  Future<void> _loadScore() async {
    final scoreBox = await Hive.openBox<int>('scoreBox');
    setState(() {
      _score = scoreBox.get('score', defaultValue: 0)!;
    });
  }

  void _showScoreInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "COME AUMENTARE IL TUO PUNTEGGIO",
            style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "COMPLETA LE ATTIVITÀ COME CUCINARE 🍲 E VESTIRTI 👗. OGNI VOLTA CHE FINISCI, IL TUO PUNTEGGIO SALE DI 100 PUNTI! 🎉 DIVERTITI!",
            style: GoogleFonts.openSans(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "OK",
                style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SCEGLI COSA DEVI FARE',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: const AppDrawer(),
      body: Container(
        color: Colors.white, // Colore di sfondo chiaro
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              onTap: () => _showScoreInfo(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, size: 60, color: Colors.amber),
                  const SizedBox(width: 15),
                  Text(
                    'PUNTEGGIO: $_score',
                    style: GoogleFonts.openSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(8),
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.9,
                children: [
                  _buildSquareButton(context, Icons.soup_kitchen, 'CUCINARE'),
                  _buildSquareButton(context, Icons.accessibility_new, 'VESTIRMI'),
                  _buildSquareButton(context, Icons.local_grocery_store, 'FARE LA SPESA'),
                  _buildSquareButton(context, Icons.fitness_center, 'ALLENARMI'),
                  _buildSquareButton(context, Icons.cleaning_services, 'PULIRE CASA'),
                  _buildSquareButton(context, Icons.local_laundry_service, 'LAVATRICE'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareButton(BuildContext context, IconData icon, String text) {
    return Semantics(
      label: text,
      button: true,
      child: InkWell(
        onTap: () => _onTapButton(context, text),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, // Dimensioni maggiori per facilitare il tocco
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blueAccent, // Colore vivace e ad alto contrasto
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 50, // Icona più grande
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: GoogleFonts.openSans(
                fontSize: 20, // Testo più grande
                fontWeight: FontWeight.bold,
                color: Colors.black87, // Colore del testo ad alto contrasto
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onTapButton(BuildContext context, String text) {
    if (text == 'CUCINARE') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const CookingPage(),
      ));
    } else if (text == 'VESTIRMI') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MeteoPage(), // Assicurati che MeteoPage sia correttamente implementata
      ));
    } else {
      // Implementa la navigazione o le azioni per le altre attività
      // Ad esempio, mostra una pagina specifica per ogni attività
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hai selezionato: $text'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Incrementa il punteggio (esempio)
      _incrementScore(100);
    }
  }

  Future<void> _incrementScore(int points) async {
    final scoreBox = await Hive.openBox<int>('scoreBox');
    setState(() {
      _score += points;
      scoreBox.put('score', _score);
    });
  }
}
