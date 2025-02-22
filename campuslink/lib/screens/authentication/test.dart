import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> loginUser() async {
  final url = 'http://192.168.1.5/clink/api/login.php';
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({
    'username': 'abel',
    'password': '12345678',
    'institution': 'ebenezer',
    'userType': 'admin'
  });

  final response = await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      print('Login successful');
    } else {
      print('Login failed: ${data['message']}');
    }
  } else {
    print('Server error: ${response.statusCode}');
  }
}
void main(){
  loginUser();
}