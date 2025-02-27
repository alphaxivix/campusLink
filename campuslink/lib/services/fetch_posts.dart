import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campuslink/data/config.dart';

// Define the Post class with a fromJson constructor.
class Post {
  final int id;
  final String userId;
  final String content;
  final String? mediaUrl; // Make mediaUrl nullable
  final String createdAt;
  final int likesCount;
  final String username;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    this.mediaUrl, // Make mediaUrl nullable
    required this.createdAt,
    required this.likesCount,
    required this.username,
  });

  // Convert a map into a Post object.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] is int ? json['id'] : int.parse(json['id']),
      userId: json['user_id'],
      content: json['content'],
      mediaUrl: json['media_url'], // No need to parse, can be null
      createdAt: json['created_at'],
      likesCount: json['likes_count'] is int ? json['likes_count'] : int.parse(json['likes_count']),
      username: json['username'],
    );
  }
}

Future<List<Post>> fetchPosts() async {
  final response = await http.get(Uri.parse('${Config.baseUrl}/clink/api/community/fetch_post.php'));
  
  if (response.statusCode == 200) {
    // Decode the JSON response into a Map.
    Map<String, dynamic> responseBody = json.decode(response.body);
    
    if (responseBody['status'] == 'success') {
      // Decode the data field into a List of Maps.
      List<dynamic> postsJson = responseBody['data'];
      
      // Convert the List<dynamic> into a List<Post>.
      return postsJson.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception("Failed to load posts: ${responseBody['message']}");
    }
  } else {
    throw Exception("Failed to load posts");
  }
}

void main() {
  fetchPosts().then((posts) {
    for (var post in posts) {
      print('Post ID: ${post.id}, Content: ${post.content}, Username: ${post.username}, Media URL: ${post.mediaUrl}');
    }
  }).catchError((error) {
    print('Error: $error');
  });
}