import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../screens/home_screen.dart';
import '../screens/weather_screen.dart';

class DettaglioConsigliPage extends StatefulWidget {
  final String categoriaMeteo;
  final String location;

  DettaglioConsigliPage({Key? key, required this.categoriaMeteo, required this.location}) : super(key: key);

  @override
  _DettaglioConsigliPageState createState() => _DettaglioConsigliPageState();
}

class _DettaglioConsigliPageState extends State<DettaglioConsigliPage> {
  late ConfettiController _controller;
  late Box<int> _scoreBox;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 5));
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
    _controller.dispose();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettagli Consigli per ${widget.location}'),
      ),
      body: FutureBuilder<Box>(
        future: Hive.openBox('consigliBox'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Text("Errore durante l'apertura del box Hive");
            } else {
              var box = snapshot.data;
              var key = 'Consigli/${widget.categoriaMeteo}/Luoghi/${widget.location}';
              var data = box!.get(key, defaultValue: {});

              // Lista ordinata degli elementi da visualizzare
              var sortedKeys = [
                if (GlobalMeteoInfo().percentualePioggia > 0 &&
                    data.containsKey('Pioggia') &&
                    GlobalMeteoInfo().percentualePioggia > 30) 'Pioggia',
                'Intimo',
                'StratoSuperiore',
                'StratoInferiore',
                if (!(GlobalMeteoInfo().percentualePioggia == 0 ||
                    (GlobalMeteoInfo().percentualePioggia > 0 &&
                        data.containsKey('Pioggia') &&
                        GlobalMeteoInfo().percentualePioggia > 30))) 'Pioggia',
                'ConsigliExtra',
              ];

              return Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(20.0),
                    children: [
                      for (var key in sortedKeys)
                        if (data.containsKey(key))
                          Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var item in data[key])
                                    if (item is String)
                                      Text(
                                        '- ${item.toUpperCase()}',
                                        style: const TextStyle(fontSize: 26.0),
                                      ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ConfettiWidget(
                      confettiController: _controller,
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
                      // Aumenta il numero di confetti
                      maxBlastForce: 80, // Aumenta l'altezza massima dei confetti
                    ),
                  ),
                ],
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _controller.play();
          _incrementScore();
          _showConfettiDialog(context);
        },
        label: const Text('Ho finito'),
        icon: const Icon(Icons.check),
      ),
    );
  }

  void _incrementScore() async {
    int currentScore = _scoreBox.get('score', defaultValue: 0)!;
    await _scoreBox.put('score', currentScore + 100);
  }

  void _showConfettiDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Congratulazioni!"),
        content: const Text("Complimenti! Hai completato l'azione."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Chiudi il dialogo
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const PrimaPagina()),
                    (route) => false,
              );
            },
            child: const Text("Chiudi"),
          ),
        ],
      ),
    );
  }
}
