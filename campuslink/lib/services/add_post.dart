// add_post.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:campuslink/data/config.dart';


Future<bool> addPost(String userId, String content, {String? mediaUrl}) async {
  try {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/clink/api/community/add_post.php'), // Replace with actual endpoint
      body: {
        'user_id': userId,
        'content': content,
        'media_url': mediaUrl ?? '',
      },
    );

    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success']) {
      return true;
    } else {
      print("Failed to add post: ${jsonResponse['message']}");
      return false;
    }
  } catch (e) {
    print("Exception caught: $e");
    return false;
  }
}
