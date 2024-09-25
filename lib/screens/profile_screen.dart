import 'dart:io';
import 'package:flutter/material.dart';
import 'package:progetti/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

enum Sesso { maschio, femmina, nessuno }

class ProfiloPage extends StatefulWidget {
  const ProfiloPage({super.key});

  @override
  _ProfiloPageState createState() => _ProfiloPageState();
}

class _ProfiloPageState extends State<ProfiloPage> {
  UserData? _userData;
  Sesso? _sessoSelezionato;
  String? _fotoProfiloPath;
  final TextEditingController _hobbyController = TextEditingController();
  final TextEditingController _sportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _recuperaDatiUtente();
    _recuperaPreferenze();
  }

  Future<void> _recuperaDatiUtente() async {
    var userData = await UserData.getUserData();
    if (userData != null) {
      setState(() {
        _userData = userData;
      });
    }
  }

  Future<void> _recuperaPreferenze() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sessoSelezionato = Sesso.values[prefs.getInt('sesso') ?? 0];
      _fotoProfiloPath = prefs.getString('fotoProfilo');
      _hobbyController.text = prefs.getString('hobby') ?? '';
      _sportController.text = prefs.getString('sport') ?? '';
    });
  }

  Future<void> _salvaPreferenze() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sesso', _sessoSelezionato!.index);
    await prefs.setString('fotoProfilo', _fotoProfiloPath ?? '');
    await prefs.setString('hobby', _hobbyController.text);
    await prefs.setString('sport', _sportController.text);
  }


  Future<void> _selezionaFotoProfilo() async {
    var permessoConcesso = await _requestPermissions();
    if (permessoConcesso) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _fotoProfiloPath = pickedFile.path;
        });
        _salvaPreferenze();
      }
    }
  }

  Future<bool> _requestPermissions() async {
    var permessoPhotos = await Permission.photos.status;
    if (!permessoPhotos.isGranted) {
      permessoPhotos = await Permission.photos.request();
      if (!permessoPhotos.isGranted) {
        return false; // Permesso non concesso
      }
    }

    // Esempio per la richiesta di permessi aggiuntivi in Android 13
    // if (Platform.isAndroid && await Permission.storage.request().isGranted) {
    //   // Verifica e richiesta per permessi specifici di Android 13, come READ_MEDIA_IMAGES
    // }

    return true; // Tutti i permessi necessari sono stati concessi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profilo')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_userData != null) Text('Ciao ${_userData!.nome}!', style: const TextStyle(fontSize: 24)),

              const SizedBox(height: 20),

              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _fotoProfiloPath != null && File(_fotoProfiloPath!).existsSync()
                        ? FileImage(File(_fotoProfiloPath!))
                        : null,
                    child: _fotoProfiloPath == null || !_fotoProfiloPath!.isNotEmpty || !File(_fotoProfiloPath!).existsSync()
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),

                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _selezionaFotoProfilo,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButton<Sesso>(
                value: _sessoSelezionato,
                onChanged: (Sesso? newValue) {
                  setState(() {
                    _sessoSelezionato = newValue;
                  });
                  _salvaPreferenze();
                },
                items: Sesso.values.map((Sesso classType) {
                  return DropdownMenuItem<Sesso>(
                    value: classType,
                    child: Text(classType.toString().split('.').last),
                  );
                }).toList(),
              ),
              TextField(
                controller: _hobbyController,
                decoration: const InputDecoration(labelText: 'Hobby'),
                onChanged: (_) => _salvaPreferenze(),
              ),
              const SizedBox(height: 16.0),

              TextField(
                controller: _sportController,
                decoration: const InputDecoration(labelText: 'Sport'),
                onChanged: (_) => _salvaPreferenze(),
              ),
              // Aggiungi qui altri campi se necessario...
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hobbyController.dispose();
    _sportController.dispose();
    super.dispose();
  }
}