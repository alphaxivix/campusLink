
import 'package:campuslink/screens/main_page.dart';
import 'package:flutter/material.dart';
import 'signup_screen.dart'; // Import the SignupScreen

class AdminLogin extends StatefulWidget {
  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true; // To toggle password visibility
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Proceed with login only if the form is valid
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(userType: 'Admin'), // Pass "Admin", "Teacher", etc.
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black.withOpacity(0.9), // Light black background
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between form and bottom
          children: [
            SizedBox(), // Empty space at the top for alignment

            // Center Content (Form)
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey, // Assign the GlobalKey
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // User Icon at the top
                      Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 80, // Icon size
                      ),
                      SizedBox(height: 20),

                      // Admin Login Title
                      Text(
                        'Admin Login',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey, // Grey color for "Admin Login"
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 40),

                      // Username TextFormField
                      TextFormField(
                        controller: _usernameController,
                        style: TextStyle(color: Colors.white), // White text color when typing
                        decoration: InputDecoration(
                          labelText: 'Email/Username',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey.shade800, // Grey background for the input field
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Password TextFormField with eye icon to show/hide password
                      TextFormField(
                        controller: _passwordController,
                        style: TextStyle(color: Colors.white), // White text color when typing
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey.shade800, // Grey background for the input field
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText; // Toggle password visibility
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),

                      // Login Button
                      GestureDetector(
                        onTap: _login, // Use the _login method
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Login',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Signup Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to the Signup Screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignupScreen()),
                              );
                            },
                            child: Text(
                              'Signup',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
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

            // CampusLink Icon and Name at the bottom center
            Padding(
              padding: EdgeInsets.only(bottom: 20), // Add spacing from bottom
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, color: Colors.white, size: 24), // CampusLink Icon
                  SizedBox(width: 8),
                  Text(
                    'CampusLink',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
