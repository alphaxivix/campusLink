import 'dart:convert';
import 'package:http/http.dart' as http;

class RasaService {
  final String rasaUrl = 'http://192.168.1.78:5005/webhooks/rest/webhook'; // Rasa server URL

  // Send a message to Rasa and get a response
  Future<List<dynamic>> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(rasaUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"sender": "user", "message": message}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to communicate with Rasa');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
