import 'package:flutter/material.dart';
import 'package:campuslink/services/fetch_media.dart';
import 'package:campuslink/services/upload_media.dart';
import 'dart:io';

class MediaProvider with ChangeNotifier {
  List<Media> _mediaList = [];
  bool _isLoading = false;

  List<Media> get mediaList => _mediaList;
  bool get isLoading => _isLoading;

  Future<void> loadMedia() async { // Renamed function
    _isLoading = true;
    notifyListeners();

    try {
      _mediaList = await fetchMedia(); // Now it uses the correct function from fetch_media.dart
    } catch (e) {
      print("Failed to fetch media: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadMedia(File file) async {
    try {
      return await uploadFile(
        file.path,
        'http://192.168.1.23/clink/api/community/upload_media.php',
      );
    } catch (e) {
      print("Failed to upload media: $e");
      return null;
    }
  }

  void addMedia(Media media) {
    _mediaList.insert(0, media);
    notifyListeners();
  }
}
