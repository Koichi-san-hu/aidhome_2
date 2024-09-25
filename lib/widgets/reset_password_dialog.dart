import 'package:flutter/material.dart';
import 'package:progetti/services/auth_service.dart'; // Assicurati che il percorso sia corretto

void showResetPasswordDialog(BuildContext context) {
  final TextEditingController resetEmailController = TextEditingController();
  final AuthService authService = AuthService(); // Ora si riferisce a AuthService e non a Auth
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Reimposta Password'),
      content: TextField(
        controller: resetEmailController,
        decoration: const InputDecoration(labelText: 'Email'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            String trimmedEmail = resetEmailController.text.trim();
            await authService.sendPasswordResetEmail(trimmedEmail); // Chiama il metodo di AuthService con l'email trim
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ti abbiamo inviato un\'email per reimpostare la tua password.')));
          },
          child: const Text('Invia'),
        ),
      ],
    ),
  );
}
//TODO: inserire dynamics link per resettare password con regole di sicurezza