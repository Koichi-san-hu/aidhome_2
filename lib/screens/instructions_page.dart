// lib/screens/instructions_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progetti/screens/home_screen.dart'; // Assicurati che questo sia il percorso corretto

class InstructionsPage extends StatefulWidget {
  final String instructions;
  final VoidCallback onFinished;

  const InstructionsPage({
    super.key,
    required this.instructions,
    required this.onFinished,
  });

  @override
  _InstructionsPageState createState() => _InstructionsPageState();
}

class _InstructionsPageState extends State<InstructionsPage> {
  late ConfettiController _confettiController;
  late Box<int> _scoreBox;

  List<String> _instructionSteps = [];
  int _currentStepIndex = 0;
  bool _isHiveInitialized = false;

  @override
  void initState() {
    super.initState();
    // Inizializza il controller del confetti con una durata di 3 secondi
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    // Inizializza Hive e carica i dati
    _initHive();
    // Suddividi le istruzioni in passaggi e pulisci ogni passaggio
    _instructionSteps = widget.instructions
        .split('\n')
        .where((step) => step.trim().isNotEmpty)
        .map((step) => _cleanInstructionStep(step))
        .toList();
  }

  /// Inizializza Hive e apre la box per il punteggio
  Future<void> _initHive() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    _scoreBox = await Hive.openBox<int>('scoreBox');
    if (!_scoreBox.containsKey('score')) {
      await _scoreBox.put('score', 0); // Inizializza il punteggio se non presente
    }
    setState(() {
      _isHiveInitialized = true;
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    Hive.close();
    super.dispose();
  }

  /// Funzione chiamata quando l'utente finisce di leggere le istruzioni
  void _finishReading() {
    _confettiController.play();
    _incrementScore();
    widget.onFinished();
    _showFinishedDialog();
  }

  /// Incrementa il punteggio salvato in Hive
  void _incrementScore() async {
    if (_isHiveInitialized) {
      int currentScore = _scoreBox.get('score', defaultValue: 0)!;
      await _scoreBox.put('score', currentScore + 100);
      print('CookingService - Punteggio incrementato a: ${currentScore + 100}');
    }
  }

  /// Mostra un dialogo di conferma al termine delle istruzioni
  void _showFinishedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "COMPLIMENTI!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Hai finito di leggere le istruzioni."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Chiudi il dialogo
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const PrimaPagina()),
                    (Route<dynamic> route) => false,
              ); // Torna alla HomeScreen
            },
            child: const Text("CHIUDI"),
          ),
        ],
      ),
    );
  }

  /// Avanza al passaggio successivo
  void _nextStep() {
    if (_currentStepIndex < _instructionSteps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
    }
  }

  /// Torna al passaggio precedente
  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
    }
  }

  /// Funzione per pulire ogni passaggio delle istruzioni
  String _cleanInstructionStep(String step) {
    // Rimuove numeri e simboli di elenco all'inizio
    String cleanedStep = step.replaceAll(RegExp(r'^(\d+\.\s+|[*\-#]+\s+)'), '');

    // Rimuove simboli di formattazione Markdown come **, *, _, ecc.
    cleanedStep = cleanedStep.replaceAll(RegExp(r'[\*\_]+'), '');

    return cleanedStep.trim();
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se Hive è stato inizializzato e se ci sono passaggi da mostrare
    if (!_isHiveInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_instructionSteps.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'ISTRUZIONI DI CUCINA',
            style: GoogleFonts.openSans(
                fontSize: 24, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blueAccent,
        ),
        body: const Center(
          child: Text(
            'NESSUNA ISTRUZIONE DISPONIBILE.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    // Recupera il passaggio corrente
    String currentStep = _instructionSteps[_currentStepIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ISTRUZIONI DI CUCINA',
          style: GoogleFonts.openSans(
              fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Indicatore di progresso
                  LinearProgressIndicator(
                    value: (_currentStepIndex + 1) / _instructionSteps.length,
                    backgroundColor: Colors.blueAccent.shade100,
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                  const SizedBox(height: 20),
                  // Titolo del passaggio
                  Text(
                    'PASSAGGIO ${_currentStepIndex + 1} DI ${_instructionSteps.length}',
                    style: GoogleFonts.openSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 20),
                  // Card contenente l'istruzione
                  Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                      ),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SingleChildScrollView(
                            child: Text(
                              currentStep, // Rimosso '• ' dal testo
                              style: GoogleFonts.openSans(
                                  fontSize: 18, color: Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Pulsanti di navigazione
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Pulsante "Indietro" solo se non si è al primo passaggio
                      _currentStepIndex > 0
                          ? ElevatedButton.icon(
                        onPressed: _previousStep,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("INDIETRO"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          textStyle: GoogleFonts.openSans(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                      // Pulsante "Avanti" o "Ho finito"
                      ElevatedButton.icon(
                        onPressed: _currentStepIndex < _instructionSteps.length - 1
                            ? _nextStep
                            : _finishReading,
                        icon: Icon(_currentStepIndex < _instructionSteps.length - 1
                            ? Icons.arrow_forward
                            : Icons.check),
                        label: Text(_currentStepIndex < _instructionSteps.length - 1
                            ? "AVANTI"
                            : "HO FINITO"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentStepIndex < _instructionSteps.length - 1
                              ? Colors.blueAccent
                              : Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          textStyle: GoogleFonts.openSans(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Effetto confetti
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
