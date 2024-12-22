import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      final userId = prefs.getString('userId') ?? '';
      final userType = prefs.getString('userType') ?? '';

      Navigator.of(context).pushReplacementNamed(
        '/main',
        arguments: {
          'userType': userType,
          'userId': userId,
        },
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/homeScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}