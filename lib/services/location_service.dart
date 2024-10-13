import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
/*
  LocationService - Gestione delle Funzionalità di Geolocalizzazione

  Questa classe si occupa di gestire le richieste di permessi di localizzazione e di ottenere la posizione
  geografica corrente dell'utente. Utilizza il pacchetto Geolocator per l'accesso alle funzionalità di
  geolocalizzazione del dispositivo.

  Caratteristiche principali:
  - Richiesta del Permesso di Localizzazione: Chiede all'utente il permesso di utilizzare i servizi di
    localizzazione del dispositivo.
  - Recupero della Posizione Corrente: Ottiene la posizione geografica attuale dell'utente con un'alta precisione.

  Utilizzo:
  - Può essere utilizzata in qualsiasi parte dell'app che richiede la posizione corrente dell'utente, come per
    funzionalità basate sulla localizzazione o per servizi che dipendono dalla posizione geografica.

  Autore: Fabio Koichi Begnini
*/

class LocationService {
  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (kDebugMode) {
        print('Latitudine: ${position.latitude}, Longitudine: ${position.longitude}');
      }
      // Qui posso fare qualcosa con la posizione ottenuta
    } else if (status.isDenied) {
      // Gestisco il caso in cui l'utente nega l'autorizzazione
    } else if (status.isPermanentlyDenied) {
      // Invito l'utente ad aprire le impostazioni dell'app
      openAppSettings();
    }
  }
}
