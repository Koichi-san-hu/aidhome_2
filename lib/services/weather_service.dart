// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importa flutter_dotenv

/*
  WeatherService - Servizio per la gestione delle chiamate API Meteo e della Geolocalizzazione
  Questa classe fornisce funzionalità essenziali per la mia app Flutter riguardanti il recupero dei dati meteo
  e la determinazione della posizione geografica dell'utente.
  Caratteristiche principali:
  - fetchWeatherData(double lat, double lon): Una funzione asincrona che effettua una chiamata API a OpenWeatherMap
    per ottenere le previsioni meteo. Utilizza la latitudine e la longitudine per ottenere dati meteo specifici
    per quella località. Ritorna un oggetto Map<String, dynamic> contenente i dati meteo o null in caso di fallimento.

  - determinePosition(): Una funzione asincrona che utilizza il pacchetto Geolocator per ottenere la posizione
    corrente dell'utente. Gestisce vari scenari quali il controllo dei permessi di localizzazione e assicura
    che i servizi di localizzazione siano abilitati.

  Utilizzo:
  - La classe viene utilizzata nelle parti dell'app dove sono necessarie informazioni meteorologiche accurate
    e/o la posizione attuale dell'utente. Ad esempio, può essere usata per visualizzare le condizioni meteo correnti
    o per ottenere previsioni meteo per la località dell'utente.

  Note:
  - È necessario disporre di una chiave API valida da OpenWeatherMap per utilizzare il servizio di previsioni meteo.
  - La gestione degli errori e delle autorizzazioni per la localizzazione è essenziale per una buona esperienza utente.

  Autori: Fabio Koichi Begnini
*/

class WeatherService {
  // Recupera l'API key dal file .env
  final String? _apiKey = dotenv.env['OPENWEATHER_API_KEY'];

  Future<Map<String, dynamic>?> fetchWeatherData(double lat, double lon) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      print('OpenWeatherMap API Key non trovata. Assicurati di averla configurata nel file .env.');
      return null;
    }

    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=it';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print("Dati ricevuti da OpenWeatherMap: ${response.body}"); // Log per debug
        return json.decode(utf8.decode(response.bodyBytes)); // Usa utf8.decode
      } else {
        print('Failed to load weather data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}'); // Log per debug
        return null;
      }
    } catch (e) {
      print('Errore nella chiamata API OpenWeatherMap: $e');
      return null;
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('I servizi di localizzazione sono disabilitati.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('I permessi di localizzazione sono stati negati.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'I permessi di localizzazione sono stati negati permanentemente, non possiamo richiedere permessi.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
