import 'package:campuslink/screens/dashboard/attendance_report.dart';
import 'package:campuslink/screens/authentication/user_login.dart';
import 'package:campuslink/screens/authentication/signup_screen.dart';
import 'package:campuslink/screens/chatbot/chatbot.dart';
import 'package:campuslink/screens/chatroom/chatroom.dart';
import 'package:campuslink/screens/community_post/community_post.dart';
import 'package:campuslink/screens/home_screen.dart';
import 'package:campuslink/screens/main_page.dart';
import 'package:campuslink/screens/profile.dart';
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
        '/adminLogin': (context) => LoginScreen(userType: "Admin",),
        '/adminSignup': (context) => SignupScreen(userType: "Admin",),
        '/main': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return MainPage(userType: args ?? 'Guest');
        },
        '/admin_attendance_report': (context) => AdminAttendanceReport(),
        '/admin_community_post': (context) => CommunityPost(),
        '/admin_chatbot': (context) => Chatbot(),
        '/adminProfile': (context) => ProfilePage(),

        // Teacher Flow
        '/teacherLogin': (context) => LoginScreen(userType: 'Teacher',),
        '/teacherAttendanceReport': (context) => AdminAttendanceReport(),
        '/teacherCommunityPost': (context) => CommunityPost(),
        '/teacherChatroom': (context) => Chatroom(),
        '/teacherChatbot': (context) => Chatbot(),
        '/teacherProfile': (context) => ProfilePage(),

        // Student Flow
        '/studentLogin': (context) => LoginScreen(userType: "Student",),
        // '/studentAttendanceReport': (context) => (),
        '/studentCommunityPost': (context) => CommunityPost(),
        '/studentChatroom': (context) => Chatroom(),
        '/studentChatbot': (context) => Chatbot(),
        '/studentProfile': (context) => ProfilePage(),

        // Guest Flow
        '/guestLogin': (context) => LoginScreen(userType: 'Guest'),
        '/guestCommunityPost': (context) => CommunityPost(),
        '/guestChatbot': (context) => Chatbot(),
      },
    );
  }
}
