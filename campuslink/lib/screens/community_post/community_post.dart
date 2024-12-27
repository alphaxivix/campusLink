import 'package:flutter/material.dart';
import '../../widgets/profile.dart';

class CommunityPost extends StatefulWidget {
  @override
  _CommunityPostState createState() => _CommunityPostState();
}

class _CommunityPostState extends State<CommunityPost> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'Community Post',
          style: theme.appBarTheme.titleTextStyle,
        ),
        iconTheme: theme.appBarTheme.iconTheme,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: theme.colorScheme.onPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SizedBox.shrink(), 
    );
  }
}
