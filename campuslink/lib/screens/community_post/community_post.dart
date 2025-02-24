import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/profile.dart';
import 'package:campuslink/services/add_post.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:campuslink/services/media_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/widgets.dart';


class CommunityPost extends StatefulWidget {
  final String username;

  const CommunityPost({Key? key, required this.username}) : super(key: key);

  @override
  _CommunityPostState createState() => _CommunityPostState();
}

class _CommunityPostState extends State<CommunityPost> {
  final TextEditingController _postController = TextEditingController();
  bool _isPosting = false;
  File? _selectedMedia;
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  bool _isUploadSectionVisible = true;

  @override
  void initState() {
    super.initState();
    Provider.of<MediaProvider>(context, listen: false).loadMedia();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {

      if (_isUploadSectionVisible) {
        setState(() {
          _isUploadSectionVisible = false;
        });
      }
    }  else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {

      if (!_isUploadSectionVisible) {
        setState(() {
          _isUploadSectionVisible = true;
        });
      }
    }
  }

  Future<void> _handleAddPost() async {
    final content = _postController.text.trim();

    if (content.isEmpty && _selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add some content or media")),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      String? mediaUrl;

      // Upload media if selected
      if (_selectedMedia != null) {
        mediaUrl = await Provider.of<MediaProvider>(context, listen: false)
            .uploadMedia(_selectedMedia!);
      }

      // Add post with content and media URL
      await addPost('123', content, mediaUrl: mediaUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Post added successfully!")),
      );

      _postController.clear();
      setState(() {
        _selectedMedia = null;
      });

      // Refresh media list
      Provider.of<MediaProvider>(context, listen: false).loadMedia();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add post: $e")),
      );
    } finally {
      setState(() => _isPosting = false);
    }
  }

  Future<void> _pickMedia() async {
    try {
      final XFile? media = await _picker.pickImage(source: ImageSource.gallery);
      if (media != null) {
        setState(() {
          _selectedMedia = File(media.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick media: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaProvider = Provider.of<MediaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'Community Post',
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file, color: theme.colorScheme.onPrimary),
            onPressed: _isPosting ? null : _handleAddPost,
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: theme.colorScheme.onPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: mediaProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: mediaProvider.mediaList.length,
                        reverse: true, // Display latest posts first
                        itemBuilder: (context, index) {
                          final media = mediaProvider.mediaList[index];
                          return PostCard(
                            username: widget.username,
                            imageUrl: media.fileUrl,
                            likes: "${(index + 1) * 457}",
                            comments: "${(index + 1) * 10}",
                            theme: theme,
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Visibility(
              visible: _isUploadSectionVisible,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _postController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Write something...",
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_selectedMedia != null) ...[
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedMedia!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.white),
                                onPressed: () => setState(() => _selectedMedia = null),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.photo_library),
                            onPressed: _pickMedia,
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            icon: Icon(Icons.send),
                            label: Text('Post'),
                            onPressed: _isPosting ? null : _handleAddPost,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String username;
  final String imageUrl;
  final String likes;
  final String comments;
  final ThemeData theme;

  const PostCard({
    Key? key,
    required this.username,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Icon(Icons.person, color: theme.colorScheme.onPrimary),
            ),
            title: Text(username, style: theme.textTheme.titleMedium),
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: FutureBuilder<File>(
              future: DefaultCacheManager().getSingleFile(imageUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 200,
                    color: theme.colorScheme.surface,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return Container(
                    height: 200,
                    color: theme.colorScheme.surface,
                    child: Center(
                      child: Text("Image not available",
                          style: theme.textTheme.bodyLarge),
                    ),
                  );
                } else {
                  return Image.file(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),
                SizedBox(width: 8),
                Text(likes, style: theme.textTheme.bodyMedium),
                SizedBox(width: 24),
                Icon(Icons.comment),
                SizedBox(width: 8),
                Text(comments, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}