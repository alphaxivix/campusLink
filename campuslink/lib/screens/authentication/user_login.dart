import 'package:campuslink/data/data_provider.dart';
import 'package:campuslink/data/save_user_data.dart';
import 'package:provider/provider.dart';
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
  final _institutionController = TextEditingController();  // New controller
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
      final institution = _institutionController.text.trim();

      if (username.isEmpty) {
        throw 'Please enter a username';
      }

      // Check institution for non-guest users
      if (!_isGuestLogin && institution.isEmpty) {
        throw 'Please enter your institution';
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

      // Add password and institution for non-guest users
      if (!_isGuestLogin) {
        requestBody['password'] = _passwordController.text;
        requestBody['institution'] = institution;
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

      if (data['status'] == 'success') {
        final userId = data['user']['user_id']?.toString() ?? '';
        final userType = widget.userType;
        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        dataProvider.currentInstitution = data['user']['institution']?.toString() ?? '';

        saveUserData(data['user']['institution']?.toString() ?? '');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', userId);
        await prefs.setString('userType', userType);
        await prefs.setString('institution', institution);  // Save institution

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/main',
          (route) => false,
          arguments: {
            'userType': userType,
            'userId': userId,
            'institution': institution,  // Pass institution to main screen
          },
        );
      } else {
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
      print('Login error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                    controller: _institutionController,
                    label: 'Institution',
                    icon: Icons.school_rounded,
                  ),
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
                  const SizedBox(height: 24),
                 if (_isAdminLogin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/adminSignup');
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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