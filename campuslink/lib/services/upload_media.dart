import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:io' show HttpOverrides;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<String?> uploadFile(String filePath, String uploadUrl) async {
  HttpOverrides.global = MyHttpOverrides(); // Bypass SSL verification

  try {
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

    var file = File(filePath);
    var fileStream = http.ByteStream(file.openRead());
    var fileLength = await file.length();

    var multipartFile = http.MultipartFile(
      'file',
      fileStream,
      fileLength,
      filename: basename(filePath),
    );

    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);
      if (jsonResponse['success']) {
        return jsonResponse['file_url'];
      } else {
        print("Upload failed: ${jsonResponse['message']}");
        return null;
      }
    } else {
      print("Error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Exception caught: $e");
    return null;
  }
}
