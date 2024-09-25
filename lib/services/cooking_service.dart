// lib/services/cooking_service.dart
import 'package:progetti/services/openai_service.dart';

class CookingService {
  final OpenAIService _openAIService = OpenAIService();

  /// Costruisce il prompt da inviare a OpenAI includendo ingredienti, numero di persone e tipi di portata.
  String buildPrompt(List<String> ingredients, int numberOfPeople, List<String> selectedCourseTypes) {
    String courseTypes = selectedCourseTypes.isNotEmpty
        ? selectedCourseTypes.map((type) => '- $type').join('\n')
        : '- Primo';

    return '''
Gli ingredienti disponibili sono:
${ingredients.map((e) => '- $e').join('\n')}

L'utente vuole preparare delle ricette per $numberOfPeople persone. I tipi di portata selezionati sono:
$courseTypes

Fornisci istruzioni passo passo chiare e semplici su cosa deve fare e per quanto tempo, assicurandoti di includere tutti i passaggi necessari, anche quelli minori come l'aggiunta di sale o olio. Utilizza punti elenco con una dimensione del testo maggiore per una migliore leggibilità.
''';
  }

  /// Genera le istruzioni di cucina basate sugli ingredienti, numero di persone e tipi di portata.
  Future<String> generateCookingInstructions(
      List<String> ingredients, int numberOfPeople, List<String> selectedCourseTypes) async {
    String prompt = buildPrompt(ingredients, numberOfPeople, selectedCourseTypes);
    // Log del prompt
    print('CookingService - Prompt inviato: \n$prompt');

    try {
      // Invia il prompt all'API di OpenAI e ottieni la risposta
      String instructions = await _openAIService.sendMessage(
        prompt,
        maxTokens: 1000,
        temperature: 0.7,
      );
      // Log della risposta
      print('CookingService - Istruzioni ricevute: \n$instructions');
      return instructions;
    } catch (e) {
      // Gestione degli errori
      print('CookingService - Errore: $e');
      return 'Errore nel generare le istruzioni. Riprova.';
    }
  }
}
