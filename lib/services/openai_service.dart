// lib/services/openai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  OpenAIService() {
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API Key non trovata. Assicurati che il file .env sia configurato correttamente.');
    }
    print('OpenAI API Key caricata correttamente.');
  }

  /// Invia una richiesta all'API di OpenAI e ritorna la risposta come stringa.
  Future<String> sendMessage(String prompt, {int maxTokens = 500, double temperature = 0.7}) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    // Costruisci il payload JSON
    Map<String, dynamic> jsonBody = {
      "model": "gpt-4", // Assicurati che il modello sia corretto
      "messages": [
        {
          "role": "system",
          "content": "Sei un assistente di cucina che aiuta persone con disabilità cognitive a preparare pasti."
        },
        {
          "role": "user",
          "content": prompt,
        }
      ],
      "max_tokens": maxTokens,
      "temperature": temperature
    };

    // Effettua la richiesta POST
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode(jsonBody),
    );

    // Gestisci la risposta
    if (response.statusCode == 200) {
      // Usa utf8.decode per decodificare i bodyBytes
      final body = json.decode(utf8.decode(response.bodyBytes));
      String reply = body['choices'][0]['message']['content'].trim();
      print('OpenAIService - Istruzioni ricevute: \n$reply'); // Log della risposta
      return reply;
    } else {
      print('OpenAIService - Errore: ${response.statusCode} - ${response.body}');
      throw Exception('Errore nella comunicazione con l\'API di OpenAI: ${response.statusCode}');
    }
  }
}
