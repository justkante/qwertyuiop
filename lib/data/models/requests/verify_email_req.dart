import 'dart:convert';

VerifyEmailReq verifyEmailReqFromJson(String str) => VerifyEmailReq.fromJson(json.decode(str));

String verifyEmailReqToJson(VerifyEmailReq data) => json.encode(data.toJson());

class VerifyEmailReq {
  final String? email;
  final String? otpCode;

  VerifyEmailReq({
    this.email,
    this.otpCode,
  });

  VerifyEmailReq copyWith({
    String? email,
    String? otpCode,
  }) =>
      VerifyEmailReq(
        email: email ?? this.email,
        otpCode: otpCode ?? this.otpCode,
      );

  factory VerifyEmailReq.fromJson(Map<String, dynamic> json) => VerifyEmailReq(
        email: json["email"],
        otpCode: json["otp_code"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "otp_code": otpCode,
      };
}
