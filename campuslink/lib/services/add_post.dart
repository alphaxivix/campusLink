import 'package:http/http.dart' as http;

Future<void> addPost(String authorId, String content, {String? mediaUrl}) async {
  final response = await http.post(
    Uri.parse('http://192.168.1.3/clink/api/community/add_post.php'),
    body: {
      'author_id': authorId,
      'content': content,
      if (mediaUrl != null) 'media_url': mediaUrl,
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to add post');
  }
}

