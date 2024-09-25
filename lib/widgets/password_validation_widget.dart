import 'package:flutter/material.dart';
/*
  PasswordValidationWidget - Widget per la Validazione della Password

  Questo widget fornisce una rappresentazione visiva dello stato di validazione di una password inserita
  dall'utente. Controlla se la password soddisfa determinati criteri di sicurezza.

  Caratteristiche principali:
  - Controllo in tempo reale: Valida la password man mano che l'utente la digita, fornendo feedback immediato.
  - Validazione basata su criteri: Verifica la presenza di caratteri maiuscoli, minuscoli, numeri e la lunghezza
    minima della password.
  - Visualizzazione dello stato di validazione: Mostra icone e testo colorati per indicare se ciascun criterio
    è stato soddisfatto o meno.

  Utilizzo:
  - È particolarmente utile in form di registrazione o di cambio password, dove è importante guidare gli utenti
    a creare password sicure.

  Implementazione:
  - Estende StatefulWidget per gestire il cambiamento dello stato di validazione.
  - Utilizza un TextEditingController per ascoltare i cambiamenti nel campo della password.

  Autore: Fabio Koichi Begnini
*/

class PasswordValidationWidget extends StatefulWidget {
  final TextEditingController passwordController;

  const PasswordValidationWidget({super.key, required this.passwordController});

  @override
  _PasswordValidationWidgetState createState() =>
      _PasswordValidationWidgetState();
}

class _PasswordValidationWidgetState extends State<PasswordValidationWidget> {
  bool hasUpperCase = false;
  bool hasLowerCase = false;
  bool hasDigit = false;
  bool hasLetter = false;

  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final password = widget.passwordController.text;

    setState(() {
      hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      hasLowerCase = password.contains(RegExp(r'[a-z]'));
      hasDigit = password.contains(RegExp(r'\d'));
      hasLetter = password.length >= 8; // Esempio: lunghezza minima di 8 caratteri
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildValidationText('Carattere maiuscolo', hasUpperCase),
        _buildValidationText('Carattere minuscolo', hasLowerCase),
        _buildValidationText('Numero', hasDigit),
        _buildValidationText('Minimo 8 caratteri', hasLetter),
      ],
    );
  }

  Widget _buildValidationText(String text, bool isValid) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          WidgetSpan(
            child: Icon(
              isValid ? Icons.check : Icons.close,
              color: isValid ? Colors.green : Colors.red,
            ),
          ),
          TextSpan(
            text: ' $text',
            style: TextStyle(
              color: isValid ? Colors.green : Colors.black,
              fontWeight: isValid ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
