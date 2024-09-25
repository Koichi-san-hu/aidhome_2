import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:progetti/services/weather_service.dart';

import 'categories_screen.dart';

class GlobalMeteoInfo {
  static final GlobalMeteoInfo _instance = GlobalMeteoInfo._internal();
  String _categoriaMeteo = '';
  int _percentualePioggia = 0;

  factory GlobalMeteoInfo() {
    return _instance;
  }

  GlobalMeteoInfo._internal();

  String get categoriaMeteo => _categoriaMeteo;
  int get percentualePioggia => _percentualePioggia;
}

class MeteoPage extends StatefulWidget {
  @override
  _MeteoPageState createState() => _MeteoPageState();
}

class _MeteoPageState extends State<MeteoPage> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  void _loadWeather() async {
    try {
      Position position = await WeatherService().determinePosition();
      Map<String, dynamic>? fullWeatherData = await WeatherService().fetchWeatherData(position.latitude, position.longitude);
      if (fullWeatherData != null) {
        DateTime now = DateTime.now();
        DateTime targetTime = now.add(Duration(hours: 3));
        int index = fullWeatherData['list'].indexWhere((data) => DateTime.parse(data['dt_txt']).isAfter(targetTime));
        if (index != -1) {
          weatherData = fullWeatherData['list'][index];
          updateGlobalCategoria(weatherData!['main']['temp'], (weatherData!['pop'] * 100).toInt());
        }
      }
    } catch (e) {
      print('Errore durante il caricamento dei dati meteo: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  void updateGlobalCategoria(dynamic temp, int pop) {
    double temperature = temp.toDouble(); // Converti il valore della temperatura in double
    GlobalMeteoInfo()._categoriaMeteo = categorizeTemperature(temperature);
    GlobalMeteoInfo()._percentualePioggia = pop;
  }


  String categorizeTemperature(double temp) {
    if (temp < 5) {
      return 'Molto Freddo';
    } else if (temp >= 5 && temp < 15) {
      return 'Freddo';
    } else if (temp >= 15 && temp < 25) {
      return 'Temperato';
    } else if (temp >= 25 && temp < 35) {
      return 'Caldo';
    } else {
      return 'Molto Caldo';
    }
  }

  void navigateToCategoriaMeteoPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CategoriaMeteoPage(categoriaMeteo: GlobalMeteoInfo()._categoriaMeteo),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meteo')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : weatherData == null
          ? Center(child: Text('Nessuna previsione disponibile per le prossime 3 ore'))
          : ListView(
        children: [
          ListTile(
            leading: Icon(Icons.thermostat),
            title: Text('Temperatura: ${weatherData!['main']['temp']} °C'),
          ),
          ListTile(
            leading: Icon(Icons.cloud),
            title: Text('Categoria Meteo: ${GlobalMeteoInfo()._categoriaMeteo}'),
          ),
          ListTile(
            leading: Icon(Icons.beach_access),
            title: Text('Probabilità di Pioggia: ${weatherData!['pop'] * 100}%'),
          ),
          SizedBox(height: 10),
          Text(
            'ORA POTRAI SCEGLIERE DOVE DEVI ANDARE e PREPARARTI DI CONSEGUENZA 🌞🌧️',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 36),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                navigateToCategoriaMeteoPage(context);
              },
              child: Text(
                'SONO PRONTO',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
