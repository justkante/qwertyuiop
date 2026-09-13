// To parse this JSON data, do
//
//     final appleSignInReq = appleSignInReqFromJson(jsonString);

import 'dart:convert';

AppleSignInReq appleSignInReqFromJson(String str) => AppleSignInReq.fromJson(json.decode(str));

String appleSignInReqToJson(AppleSignInReq data) => json.encode(data.toJson());

class AppleSignInReq {
  final String? name;
  final String? email;
  final String? authCode;
  final String? userId;
  final String? identityToken;

  AppleSignInReq({
    this.name,
    this.email,
    this.authCode,
    this.userId,
    this.identityToken,
  });

  AppleSignInReq copyWith({
    String? name,
    String? email,
    String? authCode,
    String? userId,
    String? identityToken,
  }) =>
      AppleSignInReq(
        name: name ?? this.name,
        email: email ?? this.email,
        authCode: authCode ?? this.authCode,
        userId: userId ?? this.userId,
        identityToken: identityToken ?? this.identityToken,
      );

  factory AppleSignInReq.fromJson(Map<String, dynamic> json) => AppleSignInReq(
        name: json["name"],
        email: json["email"],
        authCode: json["authCode"],
        userId: json["userId"],
        identityToken: json["identityToken"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "authCode": authCode,
        "userId": userId,
        "identityToken": identityToken,
      };
}
