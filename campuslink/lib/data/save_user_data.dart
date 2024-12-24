import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserData(String institution) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('institution', institution);
  }