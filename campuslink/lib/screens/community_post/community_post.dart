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
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CommunityPostCard(
              title: "Example Post",
              author: "John Doe",
              content: "This is an example post content.",
              timeAgo: "2 hours ago",
            ),
            CommunityPostCard(
              title: "Another Post",
              author: "Jane Smith",
              content: "This is another example post content.",
              timeAgo: "5 hours ago",
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityPostCard extends StatelessWidget {
  final String title;
  final String author;
  final String content;
  final String timeAgo;

  const CommunityPostCard({
    Key? key,
    required this.title,
    required this.author,
    required this.content,
    required this.timeAgo,
  }) : super(key: key);

  Widget _buildActionButton(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: theme.textTheme.bodyMedium?.color),
      label: Text(
        label,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      shape: theme.cardTheme.shape,
      elevation: theme.cardTheme.elevation,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    author[0].toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(context, Icons.thumb_up_outlined, 'Like'),
                _buildActionButton(context, Icons.comment_outlined, 'Comment'),
                _buildActionButton(context, Icons.share_outlined, 'Share'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
