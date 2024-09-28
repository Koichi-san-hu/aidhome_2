// lib/screens/cooking_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progetti/services/cooking_service.dart';
import 'package:progetti/screens/instructions_page.dart'; // Importa la nuova pagina
import 'package:confetti/confetti.dart';
import 'package:hive/hive.dart'; // Importa Hive

class CookingPage extends StatefulWidget {
  const CookingPage({super.key});

  @override
  _CookingPageState createState() => _CookingPageState();
}

class _CookingPageState extends State<CookingPage> {
  final CookingService _cookingService = CookingService();
  List<String> _selectedIngredients = []; // Lista degli ingredienti selezionati
  bool _isLoading = false; // Stato di caricamento

  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _numberOfPeopleController =
  TextEditingController(text: '1');

  List<String> _availableIngredients = []; // Lista degli ingredienti disponibili

  // Tipi di portata disponibili
  final List<String> _courseTypes = [
    'ANTIPASTO',
    'PRIMO',
    'SECONDO',
    'DOLCE',
    'CONTORNO',
    'BEVANDA',
  ];

  List<String> _selectedCourseTypes = []; // Lista dei tipi di portata selezionati

  // Confetti Controller per l'effetto confetti
  late ConfettiController _confettiController;

  // Definizione delle costanti dei colori
  static const Color primaryBlue = Colors.blueAccent;
  static const Color secondaryLightBlue = Colors.lightBlue;
  static const Color chipSelectedColor = Colors.blueAccent;
  static const Color chipUnselectedColor = Colors.lightBlue;

  @override
  void initState() {
    super.initState();
    // Inizializza il controller del confetti con una durata di 3 secondi
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    // Recupera gli ingredienti da Hive
    _loadIngredientsFromHive();
  }

  @override
  void dispose() {
    // Pulisce i controller quando il widget viene rimosso dallo stack
    _ingredientController.dispose();
    _numberOfPeopleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// Recupera gli ingredienti dalla box Hive
  Future<void> _loadIngredientsFromHive() async {
    try {
      Box box = await Hive.openBox('consigliBox');
      List<dynamic>? ingredientiDynamic = box.get('cucinaIngredienti');

      if (ingredientiDynamic != null) {
        setState(() {
          // Converte la lista dinamica in lista di stringhe
          _availableIngredients =
              ingredientiDynamic.map((e) => e.toString()).toList();
        });
        print("Ingredienti caricati da Hive: $_availableIngredients");
      } else {
        print("Nessun ingrediente trovato in Hive.");
        // Puoi impostare una lista di default o mostrare un messaggio all'utente
      }
    } catch (e) {
      print("Errore nel caricamento degli ingredienti da Hive: $e");
      // Puoi gestire l'errore mostrando un messaggio all'utente
    }
  }

  /// Aggiunge un ingrediente alla lista selezionata
  void _addIngredient(String ingredient) {
    setState(() {
      if (!_selectedIngredients.contains(ingredient)) {
        _selectedIngredients.add(ingredient);
      } else {
        // Mostra uno SnackBar se l'ingrediente è già stato aggiunto
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text('${ingredient.toUpperCase()} È GIÀ STATO AGGIUNTO.')),
        );
      }
    });
  }

  /// Rimuove un ingrediente dalla lista selezionata
  void _removeIngredient(int index) {
    if (index >= 0 && index < _selectedIngredients.length) {
      setState(() {
        _selectedIngredients.removeAt(index);
      });
    } else {
      // Mostra uno SnackBar se l'indice non è valido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('INGREDIENTE NON TROVATO.')),
      );
    }
  }

  /// Alterna lo stato di selezione di un tipo di portata
  void _toggleCourseType(String courseType, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedCourseTypes.add(courseType);
      } else {
        _selectedCourseTypes.remove(courseType);
      }
    });
  }

  /// Genera le istruzioni di cucina utilizzando i parametri selezionati
  void _generateInstructions() async {
    if (_selectedIngredients.isEmpty) {
      // Mostra uno SnackBar se nessun ingrediente è stato selezionato
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('PER FAVORE, AGGIUNGI ALMENO UN INGREDIENTE.')),
      );
      return;
    }

    int numberOfPeople =
        int.tryParse(_numberOfPeopleController.text.trim()) ?? 1;
    if (numberOfPeople < 1) {
      // Mostra uno SnackBar se il numero di persone è inferiore a 1
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('IL NUMERO DI PERSONE DEVE ESSERE ALMENO 1.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Avvia lo stato di caricamento
    });

    try {
      // Genera le istruzioni utilizzando il servizio CookingService
      String instructions = await _cookingService.generateCookingInstructions(
        _selectedIngredients,
        numberOfPeople,
        _selectedCourseTypes,
      );

      // Verifica se il widget è ancora montato prima di utilizzare il BuildContext
      if (!mounted) return;

      // Avvia l'effetto confetti
      _confettiController.play();

      // Naviga alla pagina delle istruzioni passando le istruzioni generate
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InstructionsPage(
            instructions: instructions,
            onFinished: _onInstructionsFinished,
          ),
        ),
      );
    } catch (e) {
      // Verifica se il widget è ancora montato prima di utilizzare il BuildContext
      if (!mounted) return;

      // Mostra uno SnackBar in caso di errore durante la generazione delle istruzioni
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('ERRORE NEL GENERARE LE ISTRUZIONI. RIPROVA.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Termina lo stato di caricamento
        });
      }
    }
  }

  /// Callback chiamata quando l'utente finisce di leggere le istruzioni
  void _onInstructionsFinished() {
    // Questa funzione è gestita in InstructionsPage per navigare e aggiungere punti
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Adatta il layout quando la tastiera è aperta
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'CUCINA ASSISTITA',
          style: GoogleFonts.openSans(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryBlue,
      ),
      body: GestureDetector(
        // Chiude la tastiera quando si tocca fuori dal TextField
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          // Aggiunge padding per evitare che il contenuto si sovrapponga con la tastiera
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // Allinea i widget per evitare problemi di overflow
            children: [
              // Titolo sezione ingredienti
              Text(
                'SELEZIONA GLI INGREDIENTI DISPONIBILI:',
                style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue),
              ),
              const SizedBox(height: 10),
              // Wrapping dei FilterChip degli ingredienti disponibili
              Wrap(
                spacing: 10,
                children: _availableIngredients
                    .map((ingredient) =>
                    _ingredientChip(ingredient.toUpperCase()))
                    .toList(),
              ),
              const SizedBox(height: 20),
              // Campo di testo e bottone per aggiungere nuovi ingredienti
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ingredientController,
                      decoration: const InputDecoration(
                        hintText: 'AGGIUNGI UN INGREDIENTE',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      style: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      String newIngredient =
                      _ingredientController.text.trim();
                      if (newIngredient.isNotEmpty) {
                        _addIngredient(newIngredient.toUpperCase());
                        _ingredientController.clear();
                      }
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Visualizzazione degli ingredienti selezionati
              _selectedIngredients.isNotEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INGREDIENTI SELEZIONATI:',
                    style: GoogleFonts.openSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: List.generate(_selectedIngredients.length,
                            (index) {
                          return Chip(
                            label: Text(
                              _selectedIngredients[index],
                              style: GoogleFonts.openSans(
                                  fontSize: 16, color: Colors.white),
                            ),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () => _removeIngredient(index),
                            backgroundColor: chipSelectedColor,
                            labelStyle: const TextStyle(color: Colors.white),
                          );
                        }),
                  ),
                ],
              )
                  : Text(
                'NESSUN INGREDIENTE SELEZIONATO.',
                style: GoogleFonts.openSans(
                    fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              // Sezione per inserire il numero di persone
              Text(
                'QUANTE PERSONE?',
                style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _numberOfPeopleController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'INSERISCI IL NUMERO DI PERSONE',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                style: GoogleFonts.openSans(
                  textStyle: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Sezione per selezionare i tipi di portata
              Text(
                'QUALI PORTATE VUOI PREPARARE?',
                style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue),
              ),
              const SizedBox(height: 10),
              Column(
                children: _courseTypes.map((type) {
                  return CheckboxListTile(
                    title: Text(
                      type.toUpperCase(),
                      style: GoogleFonts.openSans(fontSize: 16),
                    ),
                    value: _selectedCourseTypes.contains(type),
                    onChanged: (bool? value) {
                      _toggleCourseType(type, value ?? false);
                    },
                    activeColor: primaryBlue,
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              // Bottone per generare le istruzioni
              ElevatedButton(
                onPressed: _isLoading ? null : _generateInstructions,
                child: _isLoading
                    ? const CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text(
                  'GENERA ISTRUZIONI',
                  style: GoogleFonts.openSans(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 30),
              // Widget per l'effetto confetti
              Align(
                alignment: Alignment.center,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.blueAccent,
                    Colors.lightBlue,
                    Colors.purple,
                    Colors.orange,
                    Colors.blue
                  ],
                  numberOfParticles: 100,
                  maxBlastForce: 80,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Crea un FilterChip per un ingrediente specifico
  Widget _ingredientChip(String ingredient) {
    final bool isSelected = _selectedIngredients.contains(ingredient);

    return FilterChip(
      // Etichetta del Chip
      label: Text(
        ingredient,
        style: GoogleFonts.openSans(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      // Stato selezionato del Chip
      selected: isSelected,
      // Callback quando il Chip viene selezionato o deselezionato
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            _selectedIngredients.add(ingredient);
          } else {
            _selectedIngredients.remove(ingredient);
          }
        });
      },
      // Colore del Chip quando selezionato
      selectedColor: chipSelectedColor,
      // Colore di sfondo del Chip quando non è selezionato
      backgroundColor: chipUnselectedColor,
      // Colore del checkmark
      checkmarkColor: Colors.white,
      // Nasconde il checkmark predefinito
      showCheckmark: false,
      // Stile del testo del Chip
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      // Padding interno del Chip
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      // Forma arrotondata del Chip
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
