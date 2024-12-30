  import 'package:campuslink/app_theme.dart';
  import 'package:campuslink/screens/authentication/user_login.dart';
  import 'package:campuslink/screens/authentication/signup_screen.dart';
  import 'package:campuslink/screens/chatbot/chatbot.dart';
  import 'package:campuslink/screens/chatroom/chatroom.dart';
  import 'package:campuslink/screens/community_post/community_post.dart';
  import 'package:campuslink/widgets/home_screen.dart';
  import 'package:campuslink/widgets/main_page.dart';
  import 'package:campuslink/widgets/profile.dart';
  import 'package:campuslink/data/data_provider.dart';
import 'package:campuslink/widgets/splash_screen.dart';
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';

  void main() {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DataProvider()),
          // Add other providers here if needed
        ],
        child: CampusLinkApp(),
      ),
    );
  }

  class CampusLinkApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CAMPUSLINK',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        home: SplashScreen(), // Use SplashScreen as home
        routes: {
          '/homeScreen': (context) => HomeScreen(),
          // Admin Flow
          '/adminLogin': (context) => LoginScreen(userType: "Admin"),
          '/adminSignup': (context) => SignupScreen(userType: "Admin"),
          '/admin_community_post': (context) => CommunityPost(),
          '/admin_chatbot': (context) => Chatbot(),
          '/adminProfile': (context) => ProfilePage(),

          // Teacher Flow
          '/teacherLogin': (context) => LoginScreen(userType: 'Teacher'),
          '/teacherCommunityPost': (context) => CommunityPost(),
          '/teacherChatroom': (context) => Chatroom(),
          '/teacherChatbot': (context) => Chatbot(),
          '/teacherProfile': (context) => ProfilePage(),

          // Student Flow
          '/studentLogin': (context) => LoginScreen(userType: "Student"),
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
        onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => MainPage(
              userType: args['userType'] as String,
              userId: args['userId'] as String,
              ),
            );
          }
          return null;
        },
      );
    }
  }