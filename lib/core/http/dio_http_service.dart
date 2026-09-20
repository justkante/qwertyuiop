import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:creatify_mobile/core/connection/connection.dart';
import 'package:creatify_mobile/core/error/api_exception.dart';
import 'package:creatify_mobile/core/error/error_handler.dart';
import 'package:creatify_mobile/core/http/http_service.dart';
import 'package:creatify_mobile/core/interceptors/token_interceptor.dart';
import 'package:creatify_mobile/core/utils/app_url.dart';

class NetworkService implements HttpService {
  late final Dio _dio;
  late CacheStore _cacheStore;
  late CacheOptions _cacheOptions;
  late TokenInterceptor _tokenInterceptor;

  NetworkService._({
    Dio? dioOverride,
    CacheOptions? cacheOptionsOverride,
    CacheStore? cacheStoreOverride,
    //bool enableCaching = true,
  }) {
    _dio = dioOverride ?? Dio(baseOptions);
    _cacheStore = cacheStoreOverride ?? MemCacheStore(maxSize: 10485760, maxEntrySize: 1048576);
    _cacheOptions = cacheOptionsOverride ??
        CacheOptions(
            store: _cacheStore,
            policy: CachePolicy.request,
            priority: CachePriority.normal,
            allowPostMethod: false);

    // Initialize token interceptor
    _tokenInterceptor = TokenInterceptor(_dio);

    getTemporaryDirectory().then((dir) {
      _cacheStore = HiveCacheStore(dir.path);

      _cacheOptions = CacheOptions(
        store: _cacheStore,
        hitCacheOnErrorExcept: [], // for offline behaviour
      );

      _dio.interceptors.addAll([
        _tokenInterceptor,
        if (kDebugMode) ...[
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: false,
            compact: false,
          ),
          DioCacheInterceptor(options: _cacheOptions),
          CurlLoggerDioInterceptor(),
        ]
      ]);
    });
  }

  static final NetworkService _instance = NetworkService._();

  factory NetworkService() => _instance;

  /// Get the dio instance
  Dio get dio => _dio;

  /// Get the token interceptor instance
  TokenInterceptor get tokenInterceptor => _tokenInterceptor;

  BaseOptions get baseOptions => BaseOptions(
        connectTimeout: const Duration(milliseconds: 60000),
        receiveTimeout: const Duration(milliseconds: 60000),
        baseUrl: baseUrl,
        headers: headers,
      );

  @override
  String get baseUrl => ApiEndpoints.baseUrl;

  @override
  Map<String, String> get headers => {
        'accept': 'application/json',
      };

  @override
  Future<Response> request(
    String path,
    RequestMethod method, {
    dynamic savePath,
    Map<String, dynamic>? queryParams,
    dynamic data,
    FormData? formData,
    CancelToken? cancelToken,
    bool enableCache = false,
    Options? options,
  }) async {
    Response response;

    try {
      switch (method) {
        case RequestMethod.post:
          await checkInternet();
          response = await _dio.post(
            path,
            queryParameters: queryParams,
            data: data,
            cancelToken: cancelToken,
            options: options,
          );
          break;
        case RequestMethod.get:
          response = await _dio.get(
            path,
            options: enableCache ? _cacheOptions.toOptions() : options,
            queryParameters: queryParams,
            data: data,
            cancelToken: cancelToken,
          );

          break;
        case RequestMethod.put:
          response = await _dio.put(
            path,
            queryParameters: queryParams,
            data: data,
            cancelToken: cancelToken,
          );
          break;
        case RequestMethod.delete:
          response = await _dio.delete(
            path,
            data: data,
          );
          break;
        case RequestMethod.upload:
          response = await _dio.post(path,
              data: formData,
              queryParameters: queryParams,
              options: options ??
                  Options(
                    headers: {
                      "Authorization": "Bearer Your Token here ",
                      "Content-Disposition": "form-data",
                      "Content-Type": "multipart/form-data",
                      'Accept': 'application/json'
                    },
                  ),
              onSendProgress: (sent, total) {});
          break;
        case RequestMethod.patch:
          response = await _dio.patch(path, queryParameters: queryParams, data: data);
          break;
        case RequestMethod.download:
          response = await _dio.download(
            path,
            savePath,
            data: data,
          );
          break;
      }
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      final responseData =
          (e.type == DioExceptionType.badResponse && e.response?.data is Map<String, dynamic>)
              ? e.response?.data as Map<String, dynamic>
              : null;
      throw ApiException(errorMessage, responseData: responseData);
    }
  }
}
