import 'package:cloud_firestore/cloud_firestore.dart';
/*
  DatabaseService - Gestione del Database Firestore per l'app Flutter

  Questa classe fornisce un'interfaccia semplificata per interagire con Cloud Firestore di Firebase.
  È progettata per centralizzare le operazioni comuni del database, come la verifica dell'esistenza di
  documenti e la creazione di nuovi record utente.

  Caratteristiche principali:
  - Verifica dell'esistenza di documenti: Implementa una funzione che verifica se un documento specifico
    esiste in una collezione, basandosi su un campo e il suo valore.
  - Creazione di record utente: Fornisce una funzione per creare un nuovo documento utente in Firestore,
    utilizzando un ID utente univoco e dati utente specifici.

  Utilizzo:
  - Viene utilizzata principalmente durante il processo di registrazione per verificare l'unicità di determinate
    informazioni (ad esempio, indirizzo email o codice fiscale) e per creare nuovi record utente nel database.
  - Può essere estesa per includere altre funzionalità di manipolazione dei dati in Firestore.

  Implementazione:
  - Utilizza l'istanza di FirebaseFirestore per interagire direttamente con il database Firestore.
  - Le funzioni sono asincrone per gestire le operazioni del database che richiedono attese (ad esempio, query di rete).

  Autore: Fabio Koichi Begnini
*/

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkIfDocExists(
      String collection, String field, String value) async {
    final querySnapshot = await _firestore
        .collection(collection)
        .where(field, isEqualTo: value)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> createUserInFirestore(
      String userId, Map<String, dynamic> userData) async {
    return await _firestore.collection('users').doc(userId).set(userData);
  }
//todo: eliminare la funzione
  // Funzione per generare e caricare tutte le combinazioni di consigli in Firestore
 /* Future<void> generateAndUploadAdvice() async {
    final _firestore = FirebaseFirestore.instance;

    // Categorie del meteo con consigli specifici, inclusa la categoria 'Pioggia' come standard
    Map<String, Map<String, dynamic>> consigliPerMeteoELuogo = {
      'MoltoCaldo': {
        'Scuola': {
          'Intimo': [
            'Canottiera traspirante (se vuoi)',
            'Calzini corti',
            'Intimo'
          ],
          'StratoSuperiore': ['Maglietta/camicia di tessuti leggeri'],
          'StratoInferiore': [
            'Pantaloni corti o pantaloni lunghi leggeri',
            'Scarpe comode leggere'
          ],
          'ConsigliExtra': [
            'Porta la tua borraccia d\'acqua',
            'occhiali da sole',
            'cappellino'
          ],
        },
        'Lavoro': {
          'Intimo': [
            'Canottiera traspirante (se vuoi)',
            'Calzini corti',
            'Intimo'
          ],
          'StratoSuperiore': [
            'Maglietta/camicia di tessuti leggeri',
            'Divisa del lavoro'
          ],
          'StratoInferiore': ['Pantaloni del lavoro', 'Scarpe del lavoro'],
          'ConsigliExtra': [
            'Porta la tua borraccia d\'acqua',
            'occhiali da sole',
            'cappellino'
          ],
        },
        'Uscita': {
          'Intimo': [
            'Canottiera traspirante (se vuoi)',
            'Calzini corti',
            'Intimo'
          ],
          'StratoSuperiore': [
            'Maglietta/canottiera/camicia di tessuti leggeri'
          ],
          'StratoInferiore': [
            'Pantaloni corti o pantaloni lunghi leggeri oppure gonna',
            'Scarpe leggere/sandali'
          ],
          'ConsigliExtra': [
            'Porta la tua borraccia d\'acqua',
            'occhiali da sole',
            'cappellino'
          ],
        },
      },
      'Caldo': {
        'Scuola': {
          'Intimo': ['Intimo leggero', 'Calzini di cotone'],
          'StratoSuperiore': ['Maglietta di cotone o tessuto traspirante'],
          'StratoInferiore': ['Pantaloni leggeri o gonna', 'Scarpe comode'],
          'ConsigliExtra': [
            'Porta una borraccia d\'acqua',
            'Cappellino per il sole se necessario'
          ],
        },
        'Lavoro': {
          'Intimo': ['Intimo leggero', 'Calzini traspiranti'],
          'StratoSuperiore': [
            'Camicia leggera o polo',
            'Eventuale divisa del lavoro se richiesta'
          ],
          'StratoInferiore': [
            'Pantaloni comodi o gonna',
            'Scarpe adeguate al contesto lavorativo'
          ],
          'ConsigliExtra': [
            'Porta la tua borraccia d\'acqua',
            'Occhiali da sole per il tragitto'
          ],
        },
        'Uscita': {
          'Intimo': ['Intimo leggero', 'Calzini di cotone'],
          'StratoSuperiore': [
            'T-shirt o top leggero',
            'Camicetta o canottiera'
          ],
          'StratoInferiore': [
            'Shorts o pantaloni leggeri',
            'Gonna',
            'Scarpe aperte o sandali'
          ],
          'ConsigliExtra': [
            'Porta una borraccia d\'acqua',
            'Occhiali da sole',
            'Cappellino o visiera'
          ],
        },
      },
      'Temperato': {
        'Scuola': {
          'Intimo': ['Intimo confortevole', 'Calzini di cotone'],
          'StratoSuperiore': ['Maglietta di cotone','Maglione o felpa leggera'],
          'StratoInferiore': ['Jeans o pantaloni di cotone', 'Scarpe chiuse'],
          'ConsigliExtra': [
            'Puoi portare una sciarpa leggera, nel caso ci fosse vento'
          ],
        },
        'Lavoro': {
          'Intimo': ['Intimo', 'Calzini'],
          'StratoSuperiore': ['Camicia e maglioncino', 'Eventuale divisa del lavoro se richiesta'],
          'StratoInferiore': ['Pantaloni o gonna', 'Scarpe formali','Eventuale divisa del lavoro se richiesta'],
          'ConsigliExtra': ['Una sciarpa leggera o un foulard'],
        },
        'Uscita': {
          'Intimo': ['Intimo', 'Calzini '],
          'StratoSuperiore': ['Maglietta a maniche lunghe o blusa'],
          'StratoInferiore': [
            'Jeans o pantaloni ',
            'Gonna',
            'Scarpe confortevoli'
          ],
          'ConsigliExtra': ['Una giacca leggera per l\'uscita'],
        },
      },
      'Freddo': {
        'Scuola': {
          'Intimo': ['Intimo pesante', 'Calzini spessi/lunghi'],
          'StratoSuperiore': ['maglietta','Maglione/felpa', 'Giacca pesante'],
          'StratoInferiore': ['Pantaloni pesanti o jeans spessi', 'Stivali/scarpe '],
          'ConsigliExtra': [
            'Cappello, guanti e sciarpa per proteggersi dal freddo'
          ],
        },
        'Lavoro': {
          'Intimo': ['Intimo termico', 'Calzini di lana'],
          'StratoSuperiore': [
            'Maglia a collo alto',
            'Eventuale divisa del lavoro se richiesta'
          ],
          'StratoInferiore': ['Pantaloni in tessuto pesante', 'Scarpe chiuse','Eventuale divisa del lavoro se richiesta'],
          'ConsigliExtra': ['Un cappotto caldo e un ombrello grande'],
        },
        'Uscita': {
          'Intimo': ['Intimo pesante', 'Calzini/calze di lana'],
          'StratoSuperiore': ['Felpa/maglione', 'Giaccone'],
          'StratoInferiore': ['Pantaloni pesanti', 'Scarpe robuste'],
          'ConsigliExtra': [
            'Accessorii caldi come cappelli e guanti',
            'Uno zaino impermeabile'
          ],
        },
      },
      'MoltoFreddo': {
        'Scuola': {
          'Intimo': ['Intimo termico ', 'Calzini termici'],
          'StratoSuperiore': ['maglietta a maniche lunghe','Maglione pesante', 'Piumino'],
          'StratoInferiore': ['Pantaloni invernali', 'Scarponi'],
          'ConsigliExtra': ['Cappello in lana, sciarpa spessa e guanti'],
        },
        'Lavoro': {
          'Intimo': ['Intimo termico', 'Calzini di lana'],
          'StratoSuperiore': [
            'Sottogiacca termico',
            'Maglione di lana',
            'Cappotto invernale',
            'Eventuale divisa del lavoro se richiesta',

          ],
          'StratoInferiore': ['Pantaloni pesanti', 'Scarpe invernali','Eventuale divisa del lavoro se richiesta'],
          'ConsigliExtra': ['sciarpa di lana','cappello pesante','guanti'],
        },
        'Uscita': {
          'Intimo': ['Canottiera termica', 'Calzini spessi'],
          'StratoSuperiore': ['Maglione a collo alto', 'Giubbotto imbottito'],
          'StratoInferiore': [
            'Jeans pesanti o pantaloni invernali',
            'Stivali con fodera',
            'Scarpe pesanti',
          ],
          'ConsigliExtra': [
            'Una termos per bevande calde',
            'Cappello',
            'Guanti',
            'Sciarpa',

          ],
        },
      },
    };

    // Pioggia come categoria universale
    Map<String, dynamic> consigliPioggia = {
      'Pioggia': ['Ombrello', 'Impermeabile', 'Scarpe chiuse'],
    };

    // Iterazione per ogni categoria meteo e luogo
    for (String meteo in consigliPerMeteoELuogo.keys) {
      for (String luogo in consigliPerMeteoELuogo[meteo]!.keys) {
        String docId = "${meteo}_${luogo}";
        Map<String, dynamic> consigli = {
          ...consigliPerMeteoELuogo[meteo]![luogo]!,
          ...consigliPioggia, // Aggiungi i consigli per la pioggia a ogni documento
        };

        // Carica i consigli nel documento corrispondente su Firestore
        await _firestore
            .collection('Consigli')
            .doc(meteo)
            .collection('Luoghi')
            .doc(luogo)
            .set(consigli);
      }
    }
  }*/
}
