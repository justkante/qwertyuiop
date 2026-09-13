// To parse this JSON data, do
//
//     final resetPasswordReq = resetPasswordReqFromJson(jsonString);

import 'dart:convert';

ResetPasswordReq resetPasswordReqFromJson(String str) =>
    ResetPasswordReq.fromJson(json.decode(str));

String resetPasswordReqToJson(ResetPasswordReq data) => json.encode(data.toJson());

class ResetPasswordReq {
  final String? email;
  final String? otpCode;
  final String? password;
  final String? passwordConfirmation;

  ResetPasswordReq({
    this.email,
    this.otpCode,
    this.password,
    this.passwordConfirmation,
  });

  ResetPasswordReq copyWith({
    String? email,
    String? otpCode,
    String? password,
    String? passwordConfirmation,
  }) =>
      ResetPasswordReq(
        email: email ?? this.email,
        otpCode: otpCode ?? this.otpCode,
        password: password ?? this.password,
        passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
      );

  factory ResetPasswordReq.fromJson(Map<String, dynamic> json) => ResetPasswordReq(
        email: json["email"],
        otpCode: json["otp_code"],
        password: json["password"],
        passwordConfirmation: json["password_confirmation"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "otp_code": otpCode,
        "password": password,
        "password_confirmation": passwordConfirmation,
      };
}
