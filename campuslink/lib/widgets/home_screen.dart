 import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 32,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'CampusLink',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              const Text(
                'Choose your role',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildRoleCard(
                      context,
                      'Admin',
                      Icons.admin_panel_settings_rounded,
                      Colors.purple,
                      () => Navigator.pushNamed(context, '/adminLogin'),
                    ),
                    _buildRoleCard(
                      context,
                      'Teacher',
                      Icons.person_rounded,
                      Colors.green,
                      () => Navigator.pushNamed(context, '/teacherLogin'),
                    ),
                    _buildRoleCard(
                      context,
                      'Student',
                      Icons.school_rounded,
                      Colors.orange,
                      () => Navigator.pushNamed(context, '/studentLogin'),
                    ),
                    _buildRoleCard(
                      context,
                      'Guest',
                      Icons.person_outline_rounded,
                      Colors.blue,
                      () => Navigator.pushNamed(context, '/guestLogin'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

