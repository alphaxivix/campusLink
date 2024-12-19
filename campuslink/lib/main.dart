import 'package:campuslink/screens/admin_dashboard.dart/admin_attendance_report.dart';
import 'package:campuslink/screens/admin_dashboard.dart/admin_dashboard.dart';
import 'package:campuslink/screens/authentication/admin_login.dart';
import 'package:campuslink/screens/authentication/signup_screen.dart';
import 'package:campuslink/screens/authentication/student_login.dart';
import 'package:campuslink/screens/authentication/teacher_login.dart';
import 'package:campuslink/screens/chatbot/chatbot.dart';
import 'package:campuslink/screens/chatroom/chatroom.dart';
import 'package:campuslink/screens/community_post/community_post.dart';
import 'package:campuslink/screens/home_screen.dart';
import 'package:campuslink/screens/profile.dart';
import 'package:campuslink/screens/guest_dashboard/guest_dashboard.dart';
import 'package:flutter/material.dart';


void main()  {
  runApp(CampusLinkApp());
}

class CampusLinkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CAMPUSLINK',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),

        // Admin Flow
        '/adminLogin': (context) => AdminLogin(),
        '/signup': (context) => SignupScreen(),
        '/admin_dashboard': (context) => AdminDashboard(),
        '/admin_attendance_report': (context) => AdminAttendanceReport(),
        '/admin_community_post': (context) => CommunityPost(),
        '/admin_chatbot': (context) => Chatbot(),
        '/adminProfile': (context) => ProfilePage(),

        // Teacher Flow
        '/teacherLogin': (context) => TeacherLogin(),
        // '/teacherDashboard': (context) => (),
        '/teacherAttendanceReport': (context) => AdminAttendanceReport(),
        '/teacherCommunityPost': (context) => CommunityPost(),
        '/teacherChatroom': (context) => Chatroom(),
        '/teacherChatbot': (context) => Chatbot(),
        '/teacherProfile': (context) => ProfilePage(),

        // Student Flow
        '/studentLogin': (context) => StudentLogin(),
        // '/studentDashboard': (context) => StudentDashboard(),
        // '/studentAttendanceReport': (context) => (),
        '/studentCommunityPost': (context) => CommunityPost(),
        '/studentChatroom': (context) => Chatroom(),
        '/studentChatbot': (context) => Chatbot(),
        '/studentProfile': (context) => ProfilePage(),

        // Guest Flow
        '/guestDashboard': (context) => GuestDashboard(),
        '/guestCommunityPost': (context) => CommunityPost(),
        '/guestChatbot': (context) => Chatbot(),
      },
    );
  }
}
