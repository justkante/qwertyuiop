import 'package:dio/dio.dart';

/// Http Service Interface
abstract class HttpService {
  /// Http base url
  String get baseUrl;

  /// Http headers
  Map<String, String> get headers;

  /// Http get request
  Future<Response> request(
    String path,
    RequestMethod method, {
    dynamic savePath,
    Map<String, dynamic>? queryParams,
    dynamic data,
    FormData? formData,
    CancelToken? cancelToken,
    Options? options,
    bool enableCache,
  });
}

enum RequestMethod { post, get, put, delete, download, patch, upload }
