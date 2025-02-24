import 'dart:convert';
import 'package:http/http.dart' as http;

// Define the Media model
class Media {
  final int id;
  final String fileName;
  final String fileUrl;

  Media({required this.id, required this.fileName, required this.fileUrl});

  // Factory method to parse JSON
  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: int.parse(json['id'].toString()), // Safely parse id as int
      fileName: json['file_name'],
      fileUrl: json['file_url'],
    );
  }
}
// // Define the fetchMedia function
// Future<List<Media>> fetchMedia() async {
//   const String apiUrl = 'http://192.168.1.4/campuslink/api/fetch_media.php'; // Replace with your API URL
//   final response = await http.get(Uri.parse(apiUrl));

//   if (response.statusCode == 200) {
//     final List<dynamic> data = json.decode(response.body);
//     return data.map((json) => Media.fromJson(json)).toList();
//   } else {
//     throw Exception('Failed to loadmedia');
//     }
//}
Future<List<Media>> fetchMedia() async {
  String apiUrl = 'http://192.168.1.3/clink/api/community/fetch_media.php';
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    if (jsonResponse['success']) {
      List<dynamic> mediaJson = jsonResponse['media'];
      return mediaJson.map((media) => Media.fromJson(media)).toList();
    } else {
      throw Exception("API Error: ${jsonResponse['message']}");
    }
  } else {
    throw Exception("Failed to fetch media. Status code: ${response.statusCode}");
  }
}
void main() async {
  try {
    List<Media> mediaList = await fetchMedia();
    for (var media in mediaList) {
      print('Media ID: ${media.id}, Name: ${media.fileName}, URL: ${media.fileUrl}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
