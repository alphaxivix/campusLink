// Theme configuration
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Color(0xFF1A1A1A),
    primaryColor: Color(0xFF2D2D2D),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF6C63FF),
      secondary: Color(0xFF03DAC6),
      surface: Color(0xFF2D2D2D),
      background: Color(0xFF1A1A1A),
    ),
    cardColor: Color(0xFF2D2D2D),
    dividerColor: Colors.white12,
  );
}

// Animated Stat Card
class AnimatedStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const AnimatedStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 30),
          ).animate().fadeIn().scale(),
          SizedBox(height: 15),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().slideX().fadeIn(),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ).animate().slideX(delay: Duration(milliseconds: 200)).fadeIn(),
        ],
      ),
    );
  }
}

// Modern App Bar
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const ModernAppBar({
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF03DAC6),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

// Modern Chat Message Bubble
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isUser ? Color(0xFF6C63FF) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.grey[300],
            fontSize: 16,
          ),
        ),
      ),
    ).animate().slideX(
      begin: isUser ? 1 : -1,
      duration: Duration(milliseconds: 300),
    ).fadeIn();
  }
}

// Modern Community Post Card
class CommunityPostCard extends StatelessWidget {
  final String title;
  final String author;
  final String content;
  final String timeAgo;

  const CommunityPostCard({
    required this.title,
    required this.author,
    required this.content,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).cardColor,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF6C63FF),
                  child: Text(author[0].toUpperCase()),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(color: Colors.grey[300]),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.thumb_up_outlined, 'Like'),
                _buildActionButton(Icons.comment_outlined, 'Comment'),
                _buildActionButton(Icons.share_outlined, 'Share'),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildActionButton(IconData icon, String label) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.grey[400]),
      label: Text(label, style: TextStyle(color: Colors.grey[400])),
    );
  }
}