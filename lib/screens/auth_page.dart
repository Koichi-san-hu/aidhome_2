import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:progetti/screens/home_screen.dart';
import '../utils/utils.dart';
import 'email_verification_page.dart';
import 'package:progetti/services/auth_service.dart';
import 'package:progetti/services/firebase_database_service.dart';
import 'package:progetti/widgets/reset_password_dialog.dart';
import 'package:progetti/widgets/password_validation_widget.dart';
/*
  AuthPage - Pagina di Autenticazione per l'app Flutter
  Questa pagina gestisce le funzionalità di autenticazione, inclusi il login e la registrazione degli utenti.
  Fornisce un'interfaccia utente reattiva dove gli utenti possono inserire le loro credenziali per accedere o
  registrarsi nell'app.
  Caratteristiche principali:
  - Form di Login/Registrazione: Permette agli utenti di effettuare l'accesso o di creare un nuovo account.
  - Validazione dei dati: Assicura che le informazioni inserite siano valide e rispettino determinati criteri,
    come la forza della password.
  - Gestione degli errori: Visualizza messaggi di errore in caso di credenziali errate o problemi nell'accesso.
  - Reset della password: Offre agli utenti la possibilità di reimpostare la loro password.
  - Protezione dei dati: Usa un approccio sicuro per la gestione delle credenziali dell'utente.

  La classe `AuthPage` è uno StatefulWidget, poiché gestisce lo stato relativo all'input dell'utente e alle azioni
  di autenticazione. Utilizza i servizi `AuthService` e `DatabaseService` per l'interazione con Firebase
  per l'autenticazione e lo storage dei dati utente.

  Autori: Fabio Koichi Begnini
*/
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Ottiene il testo corrente
    String currentText = newValue.text;

    // Buffer per costruire il nuovo testo con le slash
    StringBuffer buffer = StringBuffer();
    int offset = newValue.selection.end;

    // Ciclo attraverso il testo corrente e aggiungi le slash dove necessario
    for (int i = 0; i < currentText.length; i++) {
      // Aggiungi il carattere corrente al buffer
      buffer.write(currentText[i]);

      // Se l'indice è 1 o 3 (cioè dopo il secondo o il quarto numero) e il prossimo carattere non è già una slash
      // e non siamo all'ultimo carattere (per evitare di aggiungere una slash alla fine)
      if ((i == 1 || i == 3) && (i + 1 < currentText.length && currentText[i + 1] != '/')) {
        buffer.write('/'); // Aggiungi una slash
        // Se la posizione corrente del cursore è dopo la posizione in cui inseriamo la slash, aggiusta il offset
        if (i < offset) {
          offset++;
        }
      }
    }

    // Crea il nuovo valore di editing con il testo aggiornato e il cursore spostato di conseguenza
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController(); // Controller per l'email
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController(); // Controller per la data di nascita

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _dateOfBirthController.dispose(); // Dispose del controller della data di nascita
    super.dispose();
  }

  void _resetPassword() {
    showResetPasswordDialog(context);
  }

  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  String _name = '';
  String _surname = '';
  bool _isLogin = true;
  String _confirmPassword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildLoginForm(),
    );
  }

  Widget buildLoginForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 36, 16, 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isLogin)
              CircleAvatar(
                radius: 70,
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: Image.asset('assets/icons/logo.png'),
                ),
              ),
            const SizedBox(height: 20),
            if (!_isLogin)
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) =>
                value!.isEmpty ? 'Per favore, inserisci un nome' : null,
                onSaved: (value) => _name = value ?? '',
              ),
            const SizedBox(height: 16.0),
            if (!_isLogin)
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cognome'),
                validator: (value) =>
                value!.isEmpty ? 'Per favore, inserisci un cognome' : null,
                onSaved: (value) => _surname = value ?? '',
              ),
            const SizedBox(height: 16.0),
            if (!_isLogin)
              TextFormField(
                controller: _dateOfBirthController,
                decoration: const InputDecoration(
                  labelText: 'Data di Nascita (GG/MM/AAAA)',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  DateInputFormatter(),
                ],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Per favore, inserisci la tua data di nascita';
                  }
                  // Aggiungi qui ulteriori validazioni se necessario
                  return null;
                },
              ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) =>
              value!.isEmpty ? 'Per favore, inserisci un\'email' : null,
              onSaved: (value) => _email = value?.trim() ?? '',
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_passwordVisible,
              validator: (value) =>
              value!.isEmpty ? 'Per favore, inserisci una password' : null,
              onSaved: (value) => _password = value ?? '',
              onChanged: (value) => _password = value,
            ),
            const SizedBox(height: 16.0),
            if (!_isLogin)
              PasswordValidationWidget(passwordController: _passwordController),
            const SizedBox(height: 16.0),
            if (!_isLogin)
              TextFormField(
                decoration: const InputDecoration(labelText: 'Conferma Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Per favore, conferma la password';
                  }
                  if (value != _password) {
                    return 'Le password non corrispondono';
                  }
                  return null;
                },
                onSaved: (value) => _confirmPassword = value ?? '',
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _isLogin ? 'Login' : 'Registrati',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              child: Text(_isLogin
                  ? 'Hai bisogno di un account? Registrati'
                  : 'Hai già un account? Accedi'),
              onPressed: () => setState(() => _isLogin = !_isLogin),
            ),
            if (_isLogin)
              TextButton(
                onPressed: _resetPassword,
                child: const Text(
                  'Hai dimenticato la password?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true; // Attiva l'indicatore di caricamento
    });

    try {
      if (_isLogin) {
        // Logica di login
        await _authService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),  // Usa il valore trim
          password: _password,
          context: context,
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => PrimaPagina()),
        );
      } else {
        // Logica di registrazione
        bool emailExists = await _databaseService.checkIfDocExists(
          'users', 'email', _emailController.text.trim(),
        );
        if (emailExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('L\'email è già in uso')),
          );
          return;
        }

        UserCredential userCredential = await _authService
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),  // Usa il valore trim
          password: _password,
        );

        String uniqueKey = await generateUniqueKey(_databaseService);
        await _databaseService.createUserInFirestore(userCredential.user!.uid, {
          'nome': _name,
          'cognome': _surname,
          'data_di_nascita': _dateOfBirthController.text,
          // Salva la data di nascita
          'email': _emailController.text.trim(),  // Usa il valore trim
          'chiaveRiconoscimento': uniqueKey,
          'MaxUsageApp': "3",
        });

        await _authService.sendEmailVerification(userCredential.user!);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const EmailVerificationPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Gestione delle eccezioni di Firebase Authentication
      String errorMessage = 'Si è verificato un errore: ';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage +=
          'Un account esistente utilizza un metodo di autenticazione diverso per la stessa email.';
          break;
        case 'user-disabled':
          errorMessage += 'Questo utente è stato disabilitato.';
          break;
        case 'invalid-email':
          errorMessage += 'L\'email fornita non è valida.';
          break;
        case 'weak-password':
          errorMessage += 'La password fornita è troppo debole.';
          break;
        case 'email-already-in-use':
          errorMessage += 'L\'email fornita è già in uso da un altro account.';
          break;
      // Aggiungi qui altri casi di errore se necessario
        default:
          errorMessage += 'Errore sconosciuto: ${e.code}';
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Gestione di altre eccezioni non legate a Firebase Authentication
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Si è verificato un errore: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Disattiva l'indicatore di caricamento
      });
    }
  }
}
