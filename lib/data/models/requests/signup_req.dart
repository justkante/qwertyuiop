import 'dart:convert';

SignUpReq signUpReqFromJson(String str) => SignUpReq.fromJson(json.decode(str));

String signUpReqToJson(SignUpReq data) => json.encode(data.toJson());

class SignUpReq {
  final String? name;
  final String? email;
  final String? password;
  final String? referralCode;
  final String? countryCode;

  SignUpReq({
    this.name,
    this.email,
    this.password,
    this.referralCode,
    this.countryCode,
  });

  SignUpReq copyWith({
    String? name,
    String? email,
    String? password,
    String? referralCode,
    String? countryCode,
  }) =>
      SignUpReq(
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        referralCode: referralCode ?? this.referralCode,
        countryCode: countryCode ?? this.countryCode,
      );

  factory SignUpReq.fromJson(Map<String, dynamic> json) => SignUpReq(
        name: json["name"],
        email: json["email"],
        password: json["password"],
        referralCode: json["referral_code"],
        countryCode: json["country_code"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "password": password,
        if (referralCode != null) "referral_code": referralCode,
        "country_code": countryCode,
      };
}
