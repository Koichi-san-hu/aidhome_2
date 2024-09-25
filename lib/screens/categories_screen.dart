import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/dettaglio_consigli_page.dart';

class CategoriaMeteoPage extends StatefulWidget {
  final String categoriaMeteo;

  CategoriaMeteoPage({Key? key, required this.categoriaMeteo}) : super(key: key);

  @override
  _CategoriaMeteoPageState createState() => _CategoriaMeteoPageState();
}

class _CategoriaMeteoPageState extends State<CategoriaMeteoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DOVE DEVI ANDARE?'),
      ),
      body: FutureBuilder<Box>(
        future: Hive.openBox('consigliBox'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var box = snapshot.data;
            var locations = box!.keys.where((key) => key.startsWith('Consigli/${widget.categoriaMeteo}/Luoghi')).toList();
            return Padding(
              padding: EdgeInsets.all(26.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: locations.map((locationKey) {
                  var location = _extractLocationName(locationKey);
                  print('Location found: $location');
                  return ElevatedButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DettaglioConsigliPage(categoriaMeteo: widget.categoriaMeteo, location: location),
                    )),
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), // Personalizza lo stile del testo
                    ),
                    child: Text(location.toUpperCase()), // Trasforma il testo in maiuscolo
                  );
                }).toList(),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  String _extractLocationName(String locationKey) {
    // Utilizza un'espressione regolare per trovare l'ultimo segmento della chiave
    RegExp regex = RegExp(r'\/Luoghi\/([^\/]+)$');
    Match? match = regex.firstMatch(locationKey);
    return match != null ? match.group(1)! : ''; // Restituisce il nome del luogo o una stringa vuota se non trovato
  }
}
