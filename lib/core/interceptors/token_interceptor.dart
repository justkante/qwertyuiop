// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/interceptors/kick_out_model.dart';
import 'package:creatify_mobile/core/storage/secure-storage/secure_storage.dart';
import 'package:creatify_mobile/core/utils/app_url.dart';
import 'package:creatify_mobile/core/utils/constants.dart';
import 'package:creatify_mobile/main.dart';
import 'package:dio/dio.dart';

class TokenInterceptor extends Interceptor {
  final Dio _dio;
  var storage = inject.get<SecureStorageBase>();

  // Cache the token in memory to avoid reading from secure storage on every request
  String? _cachedToken;

  TokenInterceptor(this._dio);

  /// Initialize and cache the token from secure storage
  Future<void> initToken() async {
    try {
      _cachedToken = await storage.readData(PrefKeys.token);
      log("Token initialized: ${_cachedToken?.isNotEmpty == true ? 'Present' : 'Empty'}");
    } catch (e) {
      log("Error initializing token: $e");
      _cachedToken = null;
    }
  }

  /// Update the cached token (call this after login or token refresh)
  void updateToken(String token) {
    _cachedToken = token;
    log("Token updated in cache");
  }

  /// Clear the cached token (call this on logout)
  void clearToken() {
    _cachedToken = null;
    log("Token cleared from cache");
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // If no cached token, try to load from storage
    if (_cachedToken == null || _cachedToken!.isEmpty) {
      _cachedToken = await storage.readData(PrefKeys.token);
    }

    log("Access Token: ${_cachedToken?.isNotEmpty == true ? 'Present' : 'Empty'}");

    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_cachedToken';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // return super.onError(err, handler);

    // if (err.response?.statusCode == 401) {
    //   // If a 401 response is received, refresh the access token

    //   String? newAccessToken = await refreshToken();
    //   if (newAccessToken != null) {
    //     _dio.options.headers['Authorization'] = 'Bearer $newAccessToken';
    //     return handler.resolve(await _dio.fetch(err.requestOptions));
    //   }

    //   // Update the request header with the new access token
    //   // err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

    //   // Repeat the request with the updated header
    // }

    // If a 401 response is received and Token is expired, Kick the User OUT!!!
    if (err.response?.statusCode == 401 && err.requestOptions.path != ApiEndpoints.instance.login) {
      eventBus.fire(KickOutListener().kickOut());
    }
    return handler.next(err);
  }

  /// Refresh Token
  // Future<String?> refreshToken() async {
  //   try {
  //     var key = ApiEndpoints.instance;
  //     String? token = await storage.readData(key.refreshToken);
  //     String? pin = await storage.readData(key.unlockPass);

  //     log("${_dio.options.headers}");

  //     final res = await _dio.post(
  //       key.changeUnlockPin,
  //       data: {"pin": pin, "refresh": token},
  //     );
  //     log("${res.data}");

  //     storage.saveData(key.token, res.data["data"]["tokens"]["access"]);
  //     storage.saveData(key.refreshToken, res.data["data"]["tokens"]["refresh"]);
  //     return res.data["data"]["tokens"]['access'];
  //   } catch (e) {
  //     throw e.toString();
  //   }
  // }

  bool shouldRefresh<R>(Response<R> response) => response.statusCode == 401;

  Future<bool> retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    await _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
    return true;
  }
}

class TokenExpiration {
  static int getExpiration(String token) {
    // var key = ApiEndpoints.instance;
    // String? token = await SecureStorage.readData(key.token);
    // Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    // int expirationTimeInSeconds = decodedToken["exp"];
    // int currentTimeInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // int timeDifferenceInSeconds =
    //     expirationTimeInSeconds - currentTimeInSeconds;
    // int timeDifferenceInMinutes = timeDifferenceInSeconds ~/ 60;

    // log("Token Expiration Time in Minutes: $timeDifferenceInMinutes");

    return -60;
  }
}
