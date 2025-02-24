import 'dart:convert';
import 'package:http/http.dart' as http;

// Define the Post class with a fromJson constructor.
class Post {
  final int id;
  final String title;
  final String content;

  Post({required this.id, required this.title, required this.content});

  // Convert a map into a Post object.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
    );
  }
}

Future<List<Post>> fetchPosts() async {
  final response = await http.get(Uri.parse('http://192.168.1.3/campuslink/api/community/fetch_post.php'));
  
  if (response.statusCode == 200) {
    // Decode the JSON response into a List of Maps.
    List<dynamic> postsJson = json.decode(response.body);
    
    // Convert the List<dynamic> into a List<Post>.
    return postsJson.map((post) => Post.fromJson(post)).toList();
  } else {
    throw Exception("Failed to load posts");
  }
}
void main(){
  final num = 1 ;
  if (num == 1) {
    fetchPosts();
  }
}