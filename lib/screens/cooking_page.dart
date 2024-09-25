// lib/screens/cooking_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progetti/services/cooking_service.dart';
import 'package:progetti/screens/instructions_page.dart'; // Importa la nuova pagina
import 'package:confetti/confetti.dart';

class CookingPage extends StatefulWidget {
  const CookingPage({super.key});

  @override
  _CookingPageState createState() => _CookingPageState();
}

class _CookingPageState extends State<CookingPage> {
  final CookingService _cookingService = CookingService();
  List<String> _selectedIngredients = [];
  bool _isLoading = false;

  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _numberOfPeopleController = TextEditingController(text: '1');

  // Lista predefinita di ingredienti disponibili
  final List<String> _availableIngredients = [
    'Pasta',
    'Sugo al pomodoro',
    'Formaggio',
    'Carne',
    'Olio',
    'Sale',
    'Pepe',
    // Aggiungi altri ingredienti predefiniti qui
  ];

  // Tipi di portata disponibili
  final List<String> _courseTypes = [
    'Antipasto',
    'Primo',
    'Secondo',
    'Dolce',
    'Contorno',
    'Bevanda',
  ];

  List<String> _selectedCourseTypes = [];

  // Confetti Controller
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _numberOfPeopleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _addIngredient(String ingredient) {
    setState(() {
      if (!_selectedIngredients.contains(ingredient)) {
        _selectedIngredients.add(ingredient);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$ingredient è già stato aggiunto.')),
        );
      }
    });
  }

  void _removeIngredient(int index) {
    if (index >= 0 && index < _selectedIngredients.length) {
      setState(() {
        _selectedIngredients.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrediente non trovato.')),
      );
    }
  }

  void _toggleCourseType(String courseType, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedCourseTypes.add(courseType);
      } else {
        _selectedCourseTypes.remove(courseType);
      }
    });
  }

  void _generateInstructions() async {
    if (_selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favore, aggiungi almeno un ingrediente.')),
      );
      return;
    }

    int numberOfPeople = int.tryParse(_numberOfPeopleController.text.trim()) ?? 1;
    if (numberOfPeople < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Il numero di persone deve essere almeno 1.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Genera le istruzioni
      String instructions = await _cookingService.generateCookingInstructions(
        _selectedIngredients,
        numberOfPeople,
        _selectedCourseTypes,
      );

      // Naviga alla pagina delle istruzioni
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore nel generare le istruzioni. Riprova.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onInstructionsFinished() {
    // Questa funzione è gestita in InstructionsPage per navigare e aggiungere punti
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Assicurati che il layout si adatti quando la tastiera è aperta
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Cucina Assistita',
          style: GoogleFonts.openSans(
              fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: GestureDetector(
        // Chiudi la tastiera quando si tocca fuori dal TextField
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          // Aggiungi padding per evitare che il contenuto si sovrapponga con la tastiera
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // Allinea i widget per evitare problemi di overflow
            children: [
              Text(
                'Seleziona gli ingredienti disponibili:',
                style: GoogleFonts.openSans(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _availableIngredients.map((ingredient) =>
                    _ingredientChip(ingredient)).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ingredientController,
                      decoration: const InputDecoration(
                        hintText: 'Aggiungi un ingrediente',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      String newIngredient = _ingredientController.text.trim();
                      if (newIngredient.isNotEmpty) {
                        _addIngredient(newIngredient);
                        _ingredientController.clear();
                      }
                    },
                    child: const Icon(Icons.add),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _selectedIngredients.isNotEmpty
                  ? Wrap(
                spacing: 8,
                children: List.generate(_selectedIngredients.length, (index) {
                  return Chip(
                    label: Text(
                      _selectedIngredients[index],
                      style: GoogleFonts.openSans(fontSize: 16),
                    ),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => _removeIngredient(index),
                    backgroundColor: Colors.blueAccent.shade100,
                    labelStyle: const TextStyle(color: Colors.white),
                  );
                }),
              )
                  : Text(
                'Nessun ingrediente selezionato.',
                style: GoogleFonts.openSans(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Text(
                'Quante persone?',
                style: GoogleFonts.openSans(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _numberOfPeopleController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Inserisci il numero di persone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Quali portate vuoi preparare?',
                style: GoogleFonts.openSans(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                children: _courseTypes.map((type) {
                  return CheckboxListTile(
                    title: Text(
                      type,
                      style: GoogleFonts.openSans(fontSize: 16),
                    ),
                    value: _selectedCourseTypes.contains(type),
                    onChanged: (bool? value) {
                      _toggleCourseType(type, value ?? false);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _generateInstructions,
                child: _isLoading
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text(
                  'Genera Istruzioni',
                  style: GoogleFonts.openSans(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
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
        ),
      ),
    );
  }
    Widget _ingredientChip(String ingredient) {
      return Semantics(
        label: ingredient,
        button: true,
        child: Chip(
          label: Text(
            ingredient,
            style: GoogleFonts.openSans(fontSize: 16, color: Colors.white),
          ),
          backgroundColor: Colors.blueAccent,
          deleteIcon: _selectedIngredients.contains(ingredient)
              ? const Icon(Icons.close, color: Colors.white)
              : const Icon(Icons.add, color: Colors.white),
          onDeleted: () {
            if (_selectedIngredients.contains(ingredient)) {
              int index = _selectedIngredients.indexOf(ingredient);
              _removeIngredient(index);
            } else {
              _addIngredient(ingredient);
            }
          },
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }
  }
