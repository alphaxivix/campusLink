
import 'package:campuslink/screens/admin_dashboard.dart/admin_dashboard.dart';
import 'package:campuslink/screens/chatbot/chatbot.dart';
import 'package:campuslink/screens/chatroom/chatroom.dart';
import 'package:campuslink/screens/community_post/community_post.dart';
import 'package:campuslink/screens/guest_dashboard/guest_dashboard.dart';
import 'package:campuslink/screens/student_dashboard/student_dashboard.dart';
import 'package:campuslink/screens/teacher_dashboard/teacher_dashboard.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final String userType; // Pass the user type as a parameter (e.g., "Guest", "Admin")

  MainPage({required this.userType});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _bottomNavItems;

  @override
  void initState() {
    super.initState();

    // Define pages and navigation items based on userType
    if (widget.userType == 'Guest') {
      _pages = [
        GuestDashboard(),
        CommunityPost(),
        Chatbot(),
      ];
      _bottomNavItems = [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_rounded),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy),
          label: 'Chatbot',
        ),
      ];
    } else if (widget.userType == 'Admin') {
      _pages = [
        AdminDashboard(),
        CommunityPost(),
        Chatroom(),
        Chatbot(),
      ];
      _bottomNavItems = [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_rounded),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_rounded),
          label: 'Chatroom',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy),
          label: 'Chatbot',
        ),
      ];
    } else if (widget.userType == 'Student') {
      _pages = [
        StudentDashboard(), // Update with StudentDashboard
        CommunityPost(),
        Chatroom(),
        Chatbot(),
      ];
      _bottomNavItems = [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_rounded),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_rounded),
          label: 'Chatroom',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy),
          label: 'Chatbot',
        ),
      ];
    } else if (widget.userType == 'Teacher') {
      _pages = [
        TeacherDashboard(), // Update with TeacherDashboard
        CommunityPost(),
        Chatroom(),
        Chatbot(),
      ];
      _bottomNavItems = [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_rounded),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_rounded),
          label: 'Chatroom',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy),
          label: 'Chatbot',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 41, 51, 56),
        selectedItemColor: const Color.fromARGB(255, 121, 130, 139),
        unselectedItemColor: Colors.white,
        currentIndex: _currentIndex,
        elevation: 12,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _bottomNavItems,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue[700],
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
