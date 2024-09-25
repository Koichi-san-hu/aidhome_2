// lib/screens/instructions_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progetti/screens/home_screen.dart';

class InstructionsPage extends StatefulWidget {
  final String instructions;
  final VoidCallback onFinished;

  const InstructionsPage({super.key, required this.instructions, required this.onFinished});

  @override
  _InstructionsPageState createState() => _InstructionsPageState();
}

class _InstructionsPageState extends State<InstructionsPage> {
  late ConfettiController _confettiController;
  late Box<int> _scoreBox;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _initHive();
  }

  Future<void> _initHive() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    _scoreBox = await Hive.openBox<int>('scoreBox');
    if (!_scoreBox.containsKey('score')) {
      await _scoreBox.put('score', 0); // Initialize score if not present
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    Hive.close();
    super.dispose();
  }

  void _finishReading() {
    _confettiController.play();
    _incrementScore();
    widget.onFinished();
    _showFinishedDialog();
  }

  void _incrementScore() async {
    int currentScore = _scoreBox.get('score', defaultValue: 0)!;
    await _scoreBox.put('score', currentScore + 100);
    print('CookingService - Punteggio incrementato a: ${currentScore + 100}');
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Complimenti!"),
        content: const Text("Hai finito di leggere le istruzioni."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Chiudi il dialogo
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const PrimaPagina()),
                    (Route<dynamic> route) => false,
              ); // Torna alla prima pagina
            },
            child: const Text("Chiudi"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Suddividi le istruzioni in punti elenco
    List<String> instructionSteps = widget.instructions
        .split('\n')
        .where((step) => step.trim().isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Istruzioni di Cucina',
          style: GoogleFonts.openSans(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: instructionSteps.map((step) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '• $step',
                    style: GoogleFonts.openSans(fontSize: 18, color: Colors.black),
                  ),
                )).toList(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _finishReading,
                child: Text(
                  'Ho finito',
                  style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
              numberOfParticles: 100,
              maxBlastForce: 80,
            ),
          ),
        ],
      ),
    );
  }
}
