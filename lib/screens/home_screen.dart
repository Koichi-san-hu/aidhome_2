// lib/screens/prima_pagina.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:progetti/screens/weather_screen.dart';
import 'package:progetti/screens/cooking_page.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_drawer.dart';

class PrimaPagina extends StatefulWidget {
  const PrimaPagina({super.key});

  @override
  _PrimaPaginaState createState() => _PrimaPaginaState();
}

class _PrimaPaginaState extends State<PrimaPagina> {
  int _score = 0;
  int _credits = 0;

  @override
  void initState() {
    super.initState();
    _loadScore();
    _loadCredits();
  }

  // Carica il punteggio dall'archivio Hive
  Future<void> _loadScore() async {
    final scoreBox = await Hive.openBox<int>('scoreBox');
    setState(() {
      _score = scoreBox.get('score', defaultValue: 0)!;
    });
  }

  // Carica i crediti dall'archivio Hive
  Future<void> _loadCredits() async {
    final creditsBox = await Hive.openBox<int>('creditsBox');
    setState(() {
      _credits = creditsBox.get('credits', defaultValue: 0)!;
    });
  }

  // Mostra un dialogo con informazioni su come aumentare il punteggio
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
                style: GoogleFonts.openSans(
                    fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  // Mostra un dialogo con informazioni sui crediti
  void _showCreditsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "CREDITI",
            style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Acquista dei crediti per sbloccare le funzionalità premium e vivere un'esperienza ancora più completa!",
            style: GoogleFonts.openSans(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "OK",
                style: GoogleFonts.openSans(
                    fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  // Gestisce il tocco su un pulsante
  void _onTapButton(BuildContext context, String text) {
    if (text == 'CUCINARE') {
      if (_credits >= 2) {
        // Mostra un avviso all'utente che utilizzerà 2 crediti
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "ATTENZIONE",
                style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
              ),
              content: Text(
                "Utilizzerai 2 crediti per accedere alla funzione 'CUCINARE'. Vuoi continuare?",
                style: GoogleFonts.openSans(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "ANNULLA",
                    style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CookingPage(),
                    ));
                    _decrementCredits(2);
                  },
                  child: Text(
                    "CONTINUA",
                    style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        // Mostra un messaggio se non ci sono abbastanza crediti
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text('Non hai abbastanza crediti per usare questa funzione.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else if (text == 'VESTIRMI') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            MeteoPage(), // Assicurati che MeteoPage sia correttamente implementata
      ));
    } else {
      // Mostra un messaggio di feedback per le altre attività
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hai selezionato: $text'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Incrementa il punteggio di 100 punti (esempio)
      _incrementScore(100);
    }
  }

  // Incrementa il punteggio e aggiorna l'archivio Hive
  Future<void> _incrementScore(int points) async {
    final scoreBox = await Hive.openBox<int>('scoreBox');
    setState(() {
      _score += points;
      scoreBox.put('score', _score);
    });
  }

  // Decrementa i crediti e aggiorna l'archivio Hive
  Future<void> _decrementCredits(int points) async {
    final creditsBox = await Hive.openBox<int>('creditsBox');
    setState(() {
      _credits -= points;
      creditsBox.put('credits', _credits);
    });
  }

  // Incrementa i crediti e aggiorna l'archivio Hive
  Future<void> _incrementCredits(int points) async {
    final creditsBox = await Hive.openBox<int>('creditsBox');
    setState(() {
      _credits += points;
      creditsBox.put('credits', _credits);
    });
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
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Sezione aggiornata per mostrare crediti e punteggio
            _buildScoreAndCreditsSection(),
            const SizedBox(height: 20),
            // Griglia di attività
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(4),
                crossAxisCount: 2,
                // Due colonne
                mainAxisSpacing: 1,
                // Spazio verticale tra le righe
                crossAxisSpacing: 1,
                // Spazio orizzontale tra le colonne
                childAspectRatio: 1.2,
                // Regola l'aspetto delle celle
                children: [
                  _buildSquareButtonPremium(
                      context, Icons.soup_kitchen, 'CUCINARE'),
                  _buildSquareButton(
                      context, Icons.accessibility_new, 'VESTIRMI'),
                  _buildSquareButton(
                      context, Icons.local_grocery_store, 'FARE LA SPESA'),
                  _buildSquareButton(
                      context, Icons.fitness_center, 'ALLENARMI'),
                  _buildSquareButton(
                      context, Icons.cleaning_services, 'PULIRE CASA'),
                  _buildSquareButton(
                      context, Icons.local_laundry_service, 'LAVATRICE'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Metodo per costruire la sezione aggiornata di punteggio e crediti
  Widget _buildScoreAndCreditsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Sezione Crediti
          GestureDetector(
            onTap: () => _showCreditsInfo(context),
            child: Column(
              children: [
                Icon(Icons.monetization_on, size: 40, color: Colors.white),
                const SizedBox(height: 5),
                Text(
                  'CREDITI',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$_credits',
                  style: GoogleFonts.openSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellowAccent,
                  ),
                ),
              ],
            ),
          ),
          // Divider verticale
          Container(
            height: 60,
            width: 1,
            color: Colors.white54,
          ),
          // Sezione Punteggio
          GestureDetector(
            onTap: () => _showScoreInfo(context),
            child: Column(
              children: [
                Icon(Icons.star, size: 40, color: Colors.white),
                const SizedBox(height: 5),
                Text(
                  'PUNTEGGIO',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$_score',
                  style: GoogleFonts.openSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellowAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget per creare un pulsante quadrato
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

  // Widget per creare un pulsante quadrato con etichetta 'Premium'
  Widget _buildSquareButtonPremium(
      BuildContext context, IconData icon, String text) {
    return Semantics(
      label: '$text (Premium)',
      button: true,
      child: InkWell(
        onTap: () => _onTapButton(context, text),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 100, // Dimensioni maggiori per facilitare il tocco
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    // Colore vivace e ad alto contrasto
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
                // Etichetta 'Premium'
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Premium',
                    style: GoogleFonts.openSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
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
}
