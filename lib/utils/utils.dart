import 'dart:math';
import '../services/firebase_database_service.dart';

Future<String> generateUniqueKey(DatabaseService databaseService) async {
  const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final Random random = Random();
  final DatabaseService dbService = DatabaseService();
  String key;
  do {
    key = List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
  } while (await dbService.checkIfDocExists('users', 'chiaveRiconoscimento', key));
  return key;
}
