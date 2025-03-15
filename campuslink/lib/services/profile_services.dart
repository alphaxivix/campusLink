import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campuslink/data/config.dart';
import 'dart:io';

class ProfileService {

  Future<bool> updateProfile({
    required String userId,
    String? password,
    String? email,
    String? institution,
    File? profileImage,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.baseUrl}/clink/api/update_profile.php'),
      );

      request.fields['user_id'] = userId;
      if (password != null && password.isNotEmpty) {
        request.fields['password'] = password;
      }
      if (email != null && email.isNotEmpty) {
        request.fields['email'] = email;
      }
      if (institution != null && institution.isNotEmpty) {
        request.fields['institution'] = institution;
      }
      if (profileImage != null && !profileImage.path.startsWith('http')) {
        request.files.add(await http.MultipartFile.fromPath('profile_image', profileImage.path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final result = json.decode(responseBody);
        if (result['success'] == true) {
          // Update SharedPreferences with new values
          final prefs = await SharedPreferences.getInstance();
          if (password != null && password.isNotEmpty) {
            await prefs.setString('password', password);
          }
          if (email != null && email.isNotEmpty) {
            await prefs.setString('email', email);
          }
          if (institution != null && institution.isNotEmpty) {
            await prefs.setString('institution', institution);
          }
          if (profileImage != null) {
            await prefs.setString('profile_image', profileImage.path);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  Future<Map<String, String>> fetchUserProfile(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/clink/api/get_profile.php?username=$userId'),
    );

    print('Fetching profile for user: $userId');
    print('API Response: ${response.body}'); // Debugging output

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final user = result['data']; // Ensure it matches the API response structure

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();

        print('Fetched User Data: $user'); // Debugging output

        await prefs.setString('userId', user['user_id']);
        await prefs.setString('name', user['user_id']); // Assuming name = user_id
        await prefs.setString('institution', user['institution']);
        await prefs.setString('password', '••••••••'); // Hide hashed password
        await prefs.setString('email', user['email']);
        await prefs.setString('profile_image', user['profile_image'] ?? '');

        return {
          'userId': user['user_id'],
          'name': user['user_id'],
          'institution': user['institution'],
          'password': '••••••••',
          'email': user['email'],
          'profile_image': user['profile_image'] ?? '',
        };
      }
    }
    return {};
  } catch (e) {
    print('Error fetching user profile: $e');
    return {};
  }
}
}