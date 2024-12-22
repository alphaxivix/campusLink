import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  final String userType;
  const LoginScreen({Key? key, required this.userType}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isLoading = false;

  bool get _isAdminLogin => widget.userType.toLowerCase() == 'admin';
  bool get _isGuestLogin => widget.userType.toLowerCase() == 'guest';

Future<void> _validateAndLogin() async {
  setState(() {
    _errorMessage = null;
    _isLoading = true;
  });

  try {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      throw 'Please enter a username';
    }

    // For non-guest users, verify password
    if (!_isGuestLogin && _passwordController.text.isEmpty) {
      throw 'Please enter a password';
    }

    // Prepare request body
    Map<String, dynamic> requestBody = {
      'username': username,
      'userType': widget.userType.toLowerCase(),
    };

    // Add password only for non-guest users
    if (!_isGuestLogin) {
      requestBody['password'] = _passwordController.text;
    }

    // Make API call
    final response = await http.post(
      Uri.parse('http://192.168.1.78/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.body.isEmpty) {
      throw 'Server returned empty response';
    }

    final data = jsonDecode(response.body);

    // In _validateAndLogin method of LoginScreen
if (data['status'] == 'success') {
  // Extract user data
  final userId = data['user']['user_id']?.toString() ?? 'Guest';
  final userType = widget.userType;

  // Store login status and user data (using shared_preferences)
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
  await prefs.setString('userId', userId);
  await prefs.setString('userType', userType);

  // Navigate to MainPage and remove all previous routes
  Navigator.of(context).pushNamedAndRemoveUntil(
    '/main',
    (route) => false, // This removes all previous routes
    arguments: {
      'userType': userType,
      'userId': userId,
    },
  );
}else {
      // Show the error message from the server
      throw data['message'] ?? 'Login failed';
    }
  } catch (e) {
    setState(() {
      if (e is FormatException) {
        _errorMessage = 'Invalid server response';
      } else {
        _errorMessage = e.toString();
      }
    });
    print('Login error: $e'); // For debugging
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    // Implement secure storage of user data
    // Example using flutter_secure_storage:
    // final storage = FlutterSecureStorage();
    // await storage.write(key: 'user_data', value: jsonEncode(userData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 32),
                Text(
                  '${widget.userType} Login',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back to CampusLink',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 48),
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  icon: Icons.person_rounded,
                ),
                if (!_isGuestLogin) ...[
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_rounded,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red[300],
                      fontSize: 14,
                    ),
                  ),
                ],
                if (_isAdminLogin) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Implement forgot password functionality
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _validateAndLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isGuestLogin ? 'Continue as Guest' : 'Login',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool isPassword = false,
  bool? obscureText,
  VoidCallback? onToggleVisibility,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      controller: controller,
      obscureText: obscureText ?? false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText! ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400],
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[900],
      ),
    ),
  );
}
}