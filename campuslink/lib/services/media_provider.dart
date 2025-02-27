// filepath: /C:/project/c_link_newlatest/project/campuslink/lib/services/media_provider.dart
import 'package:flutter/material.dart';
import 'package:campuslink/services/fetch_posts.dart';
import 'package:campuslink/services/upload_media.dart';
import 'dart:io';
import 'package:campuslink/data/config.dart';

class MediaProvider with ChangeNotifier {
  List<Post> _postList = [];
  bool _isLoading = false;

  List<Post> get postList => _postList;
  bool get isLoading => _isLoading;

  Future<void> loadPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _postList = await fetchPosts();
    } catch (e) {
      print("Failed to fetch posts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadMedia(File file) async {
    try {
      return await uploadFile(
        file.path,
        '${Config.baseUrl}/clink/api/community/upload_media.php',
      );
    } catch (e) {
      print("Failed to upload media: $e");
      return null;
    }
  }
}