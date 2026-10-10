import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

class CloudinaryService {
  static const String cloudName = "Root";
  static const String apiKey = "683971691777398";
  static const String apiSecret = "-5_PhnW0U0yypLhtrFN3JsyUJfc";

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  /// Uploads a file (image, video, document) directly to Cloudinary.
  /// Returns the uploaded `secure_url` on success.
  static Future<String> uploadFile(File file) async {
    try {
      final String timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final String stringToSign = "timestamp=$timestamp$apiSecret";
      final String signature = sha1.convert(utf8.encode(stringToSign)).toString();

      final String fileName = file.path.split(RegExp(r'[/\\]')).last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'api_key': apiKey,
        'timestamp': timestamp,
        'signature': signature,
      });

      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/auto/upload',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final secureUrl = response.data['secure_url'] as String?;
        log('Cloudinary Direct Upload Success: $secureUrl');
        if (secureUrl != null) {
          return secureUrl;
        }
      }

      throw Exception('Cloudinary response error: ${response.statusMessage}');
    } catch (e) {
      log('Cloudinary Upload Error: $e');
      throw 'Cloudinary upload failed: $e';
    }
  }
}
