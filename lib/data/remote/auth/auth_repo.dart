import 'package:creatify_mobile/data/models/requests/apple_sign_in_req.dart';
import 'package:creatify_mobile/data/models/requests/change_password_req.dart';
import 'package:creatify_mobile/data/models/requests/reset_password_req.dart';
import 'package:creatify_mobile/data/models/requests/signin_req.dart';
import 'package:creatify_mobile/data/models/requests/signup_req.dart';
import 'package:creatify_mobile/data/models/requests/verify_email_req.dart';
import 'package:creatify_mobile/data/models/responses/countries_dto.dart';
import 'package:creatify_mobile/data/models/responses/user_dto.dart';
import 'package:creatify_mobile/data/remote/auth/auth_service.dart';

abstract class AuthRepo {
  Future<UserDto> signUp(SignUpReq req);
  Future<UserDto> signIn(SignInReq req);
  Future<UserDto> googleSignIn(String token);
  Future<UserDto> appleSignIn(AppleSignInReq req);
  Future<UserDto> verifyEmail(VerifyEmailReq req);
  Future<String> resendVerificationEmail({required String email});
  Future<String> resendResetPasswordCode({required String email});
  Future<String> forgotPassword({required String email});
  Future<String> verifyPasswordResetOtp(VerifyEmailReq req);
  Future<String> resetPassword(ResetPasswordReq req);
  Future<String> changePassword(ChangePasswordReq req);
  Future<String> deleteAccount({String? password});
  Future<String> setPresence(bool isOnline);
  Future<List<CountriesItemDto>> getCountries();
}

class AuthImpl implements AuthRepo {
  final AuthService _authService;

  AuthImpl(this._authService);

  @override
  Future<String> forgotPassword({required String email}) async {
    return await _authService.forgotPassword(email: email);
  }

  @override
  Future<String> resendVerificationEmail({required String email}) async {
    return await _authService.resendVerificationEmail(email: email);
  }

  @override
  Future<String> resetPassword(ResetPasswordReq req) async {
    return await _authService.resetPassword(req);
  }

  @override
  Future<UserDto> signIn(SignInReq req) async {
    return await _authService.signIn(req);
  }

  @override
  Future<UserDto> signUp(SignUpReq req) async {
    return await _authService.signUp(req);
  }

  @override
  Future<UserDto> verifyEmail(VerifyEmailReq req) async {
    return await _authService.verifyEmail(req);
  }

  @override
  Future<String> verifyPasswordResetOtp(VerifyEmailReq req) async {
    return await _authService.verifyPasswordResetOtp(req);
  }

  @override
  Future<UserDto> googleSignIn(String token) async {
    return await _authService.googleSignIn(token);
  }

  @override
  Future<UserDto> appleSignIn(AppleSignInReq req) async {
    return await _authService.appleSignIn(req);
  }

  @override
  Future<String> resendResetPasswordCode({required String email}) async {
    return await _authService.resendResetPasswordCode(email: email);
  }

  @override
  Future<String> changePassword(ChangePasswordReq req) async {
    return await _authService.changePassword(req);
  }

  @override
  Future<String> deleteAccount({String? password}) async {
    return await _authService.deleteAccount(password: password);
  }

  @override
  Future<String> setPresence(bool isOnline) async {
    return await _authService.setPresence(isOnline);
  }

  @override
  Future<List<CountriesItemDto>> getCountries() async {
    return await _authService.getCountries();
  }
}
