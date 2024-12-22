import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all stored data
      
      // Navigate to login page and clear navigation stack
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/homeScreen', // Changed from '/' to '/login' for better semantics
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Added logout button in AppBar
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.white,
            onPressed: () {
              // Show confirmation dialog before logout
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Logout'),
                    content: Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: Text('Logout'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          logout();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color.fromARGB(255, 39, 46, 58),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Picture Section
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color.fromARGB(255, 39, 46, 58), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 39, 46, 58).withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: NetworkImage(
                        'https://www.example.com/your-profile-picture.jpg',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // User Details Section
            ..._buildDetailCards([
              {'icon': Icons.person, 'title': 'Name', 'value': 'John Doe'},
              {'icon': Icons.school, 'title': 'University', 'value': 'XYZ University'},
            ]),

            // Edit Profile Button
            Container(
              margin: EdgeInsets.all(20),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Edit Profile clicked')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 39, 46, 58),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetailCards(List<Map<String, dynamic>> details) {
    return details.map((detail) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 39, 46, 58).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                detail['icon'] as IconData,
                color: Colors.black,
                size: 24,
              ),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail['title'] as String,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  detail['value'] as String,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}