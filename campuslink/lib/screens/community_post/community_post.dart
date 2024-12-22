import 'package:flutter/material.dart';
import '../../widgets/profile.dart';

class CommunityPost extends StatefulWidget {
  @override
  _CommunityPostState createState() => _CommunityPostState();
}

class _CommunityPostState extends State<CommunityPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Community Post', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
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
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.all(16),
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

// Add the CommunityPostCard widget definition
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

  Widget _buildActionButton(IconData icon, String label) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.grey[400]),
      label: Text(label, style: TextStyle(color: Colors.grey[400])),
    );
  }

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
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
    );
  }
}