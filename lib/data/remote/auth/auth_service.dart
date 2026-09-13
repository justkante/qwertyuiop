import 'package:creatify_mobile/core/http/dio_http_service.dart';
import 'package:creatify_mobile/core/http/http_service.dart';
import 'package:creatify_mobile/core/storage/hive-storage/hive_storage.dart';
import 'package:creatify_mobile/core/storage/hive-storage/hive_storage_service.dart';
import 'package:creatify_mobile/core/storage/secure-storage/secure_storage.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/core/utils/app_url.dart';
import 'package:creatify_mobile/core/utils/constants.dart';
import 'package:creatify_mobile/data/models/requests/apple_sign_in_req.dart';
import 'package:creatify_mobile/data/models/requests/change_password_req.dart';
import 'package:creatify_mobile/data/models/requests/reset_password_req.dart';
import 'package:creatify_mobile/data/models/requests/signin_req.dart';
import 'package:creatify_mobile/data/models/requests/signup_req.dart';
import 'package:creatify_mobile/data/models/requests/verify_email_req.dart';
import 'package:creatify_mobile/data/models/responses/countries_dto.dart';
import 'package:creatify_mobile/data/models/responses/user_dto.dart';

class AuthService {
  final HttpService _networkService;
  final SecureStorageBase _storage;
  final HiveStorageBase _hiveStorage;

  AuthService(
      {required HttpService networkService,
      required SecureStorageBase storage,
      required HiveStorageBase hiveStorage})
      : _networkService = networkService,
        _storage = storage,
        _hiveStorage = hiveStorage;

  Future<UserDto> signUp(SignUpReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.signUp,
        RequestMethod.post,
        data: req.toJson(),
      );

      return UserDto.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserDto> signIn(SignInReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.login,
        RequestMethod.post,
        data: req.toJson(),
      );

      // Save the token to secure storage
      await _storage.saveData(PrefKeys.token, response.data["token"]);

      // Update token in network interceptor cache for immediate use
      NetworkService().tokenInterceptor.updateToken(response.data["token"]);

      // Save the Password for Biometrics Login
      await _storage.saveData(
        PrefKeys.password,
        req.password ?? '',
      );

      // Save User to Hive Storage
      final user = UserDto.fromJson(response.data['data']);
      await _hiveStorage.set(StorageKey.userProfileData.name, user);

      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserDto> googleSignIn(String token) async {
    try {
      final response = await _networkService.request(
        endpoints.googleSignIn,
        RequestMethod.post,
        data: {
          "access_token": token,
        },
      );

      // Save the token to secure storage
      await _storage.saveData(PrefKeys.token, response.data["token"]);

      // Update token in network interceptor cache for immediate use
      NetworkService().tokenInterceptor.updateToken(response.data["token"]);

      // Save User to Hive Storage
      final user = UserDto.fromJson(response.data['data']);
      await _hiveStorage.set(StorageKey.userProfileData.name, user);

      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserDto> appleSignIn(AppleSignInReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.appleSignIn,
        RequestMethod.post,
        data: req.toJson(),
      );

      // Save the token to secure storage
      await _storage.saveData(PrefKeys.token, response.data["token"]);

      // Update token in network interceptor cache for immediate use
      NetworkService().tokenInterceptor.updateToken(response.data["token"]);

      // Save User to Hive Storage
      final user = UserDto.fromJson(response.data['data']);
      await _hiveStorage.set(StorageKey.userProfileData.name, user);

      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserDto> verifyEmail(VerifyEmailReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.verifyEmail,
        RequestMethod.post,
        data: req.toJson(),
      );

      // Save the token to secure storage
      await _storage.saveData(PrefKeys.token, response.data["token"]);

      // Update token in network interceptor cache for immediate use
      NetworkService().tokenInterceptor.updateToken(response.data["token"]);

      // Save User to Hive Storage
      final user = UserDto.fromJson(response.data['data']);
      await _hiveStorage.set(StorageKey.userProfileData.name, user);

      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> resendVerificationEmail({required String email}) async {
    try {
      final response = await _networkService.request(
        endpoints.resendVerificationCode,
        RequestMethod.post,
        data: {
          "email": email,
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> forgotPassword({required String email}) async {
    try {
      final response = await _networkService.request(
        endpoints.forgotPassword,
        RequestMethod.post,
        data: {
          "email": email,
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> resendResetPasswordCode({required String email}) async {
    try {
      final response = await _networkService.request(
        endpoints.resendResetPasswordCode,
        RequestMethod.post,
        data: {
          "email": email,
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> verifyPasswordResetOtp(VerifyEmailReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.resetPasswordVerifyCode,
        RequestMethod.post,
        data: req.toJson(),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> resetPassword(ResetPasswordReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.resetPassword,
        RequestMethod.post,
        data: req.toJson(),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> changePassword(ChangePasswordReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.changePasssword,
        RequestMethod.post,
        data: req.toJson(),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> deleteAccount({String? password}) async {
    try {
      final response = await _networkService.request(
        endpoints.deleteAccount,
        RequestMethod.post,
        data: {
          if (password != null && password.isNotEmpty) "account_password": password,
        },
      );

      // Clear secure storage
      await _storage.deleteAllData();
      SharedPrefManager.clearExceptFirstLaunch();

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> setPresence(bool isOnline) async {
    try {
      final response = await _networkService.request(
        endpoints.setPresence,
        RequestMethod.post,
        data: {
          "is_online": isOnline,
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<CountriesItemDto>> getCountries() async {
    try {
      final response = await _networkService.request(
        endpoints.country,
        RequestMethod.get,
      );

      List<CountriesItemDto> countries = (response.data['data'] as List)
          .map((countryJson) => CountriesItemDto.fromJson(countryJson))
          .toList();

      return countries;
    } catch (e) {
      throw e.toString();
    }
  }
}
