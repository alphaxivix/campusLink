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
import 'package:campuslink/services/media_provider.dart';
import 'package:campuslink/services/my_http_overrides.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:campuslink/services/firebase_api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📩 Background Message Received: ${message.notification?.title}");
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAPI.initFCM();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  String? token = await messaging.getToken();
  print("🔥 FCM Token: $token");

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => MediaProvider()),
      ],
      child: CampusLinkApp(),
    ),
  );
}

class CampusLinkApp extends StatefulWidget {
  const CampusLinkApp({super.key});

  @override
  _CampusLinkAppState createState() => _CampusLinkAppState();
}

class _CampusLinkAppState extends State<CampusLinkApp> {
  @override
  void initState() {
    super.initState();
    setupFirebaseNotifications();
  }

  void setupFirebaseNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground Notification: ${message.notification?.title}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${message.notification?.title} - ${message.notification?.body}"),
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📲 Notification Clicked: ${message.notification?.title}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CAMPUSLINK',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: SplashScreen(),
      routes: {
        '/homeScreen': (context) => HomeScreen(),
        '/adminLogin': (context) => LoginScreen(userType: "Admin"),
        '/adminSignup': (context) => SignupScreen(userType: "Admin"),
        '/admin_community_post': (context) => CommunityPost(username: 'Admin'),
        '/admin_chatbot': (context) => Chatbot(),
        '/adminProfile': (context) => ProfilePage(),
        '/teacherLogin': (context) => LoginScreen(userType: 'Teacher'),
        '/teacherCommunityPost': (context) => CommunityPost(username: 'Teacher'),
        '/teacherChatroom': (context) => Chatroom(),
        '/teacherChatbot': (context) => Chatbot(),
        '/teacherProfile': (context) => ProfilePage(),
        '/studentLogin': (context) => LoginScreen(userType: "Student"),
        '/studentCommunityPost': (context) => CommunityPost(username: 'Student'),
        '/studentChatroom': (context) => Chatroom(),
        '/studentChatbot': (context) => Chatbot(),
        '/studentProfile': (context) => ProfilePage(),
        '/guestLogin': (context) => LoginScreen(userType: 'Guest'),
        '/guestCommunityPost': (context) => CommunityPost(username: 'Guest'),
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
