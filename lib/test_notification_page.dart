// lib/test_notification_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'main.dart'; // Importa main.dart per accedere a flutterLocalNotificationsPlugin

class TestNotificationPage extends StatelessWidget {
  const TestNotificationPage({Key? key}) : super(key: key);

  // Funzione pubblica e statica per inviare una notifica immediata
  static Future<void> sendNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'test_channel_id', // ID del canale
      'Test Notifications', // Nome del canale
      channelDescription: 'Canale per le notifiche di test',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // ID della notifica
      'AidHome', // Titolo della notifica
      'BISOGNA CUCINARE! PREPARA IL TUO PASTO', // Corpo della notifica
      platformChannelSpecifics,
      payload: 'Dati di prova', // Puoi usare il payload per passare dati alla notifica
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagina di Test Notifiche'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: sendNotification,
          child: const Text('Invia Notifica'),
        ),
      ),
    );
  }
}
