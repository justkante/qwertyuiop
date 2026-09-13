import 'dart:convert';

SignInReq signInReqFromJson(String str) => SignInReq.fromJson(json.decode(str));

String signInReqToJson(SignInReq data) => json.encode(data.toJson());

class SignInReq {
  final String? email;
  final String? password;

  SignInReq({
    this.email,
    this.password,
  });

  SignInReq copyWith({
    String? email,
    String? password,
  }) =>
      SignInReq(
        email: email ?? this.email,
        password: password ?? this.password,
      );

  factory SignInReq.fromJson(Map<String, dynamic> json) => SignInReq(
        email: json["email"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
      };
}
