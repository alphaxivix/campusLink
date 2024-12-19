import 'package:campuslink/screens/main_page.dart';
import 'package:flutter/material.dart';

class StudentLogin extends StatefulWidget {
  @override
  _StudentLoginState createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
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
          builder: (context) => MainPage(userType: 'Student'), // Pass "Admin", "Teacher", etc.
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

            // Center Content (Form and Warning)
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // User Icon at the top
                      Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 80, // Icon size
                      ),
                      SizedBox(height: 20),
                  
                      // Student Login Title
                      Text(
                        'Student Login',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey, // Grey color for "Student Login"
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 40),
                  
                      // Username TextField
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
                  
                      // Warning Container with icon and text
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.warning, color: Colors.yellow, size: 20), // Warning Icon
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Only enter the username and password allowed to you by the admin.',
                                style: TextStyle(color: Colors.white, fontSize: 12), // Smaller text size
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
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
