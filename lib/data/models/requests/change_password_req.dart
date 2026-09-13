// To parse this JSON data, do
//
//     final changePasswordReq = changePasswordReqFromJson(jsonString);

import 'dart:convert';

ChangePasswordReq changePasswordReqFromJson(String str) =>
    ChangePasswordReq.fromJson(json.decode(str));

String changePasswordReqToJson(ChangePasswordReq data) => json.encode(data.toJson());

class ChangePasswordReq {
  final String? currentPassword;
  final String? newPassword;
  final String? newPasswordConfirmation;

  ChangePasswordReq({
    this.currentPassword,
    this.newPassword,
    this.newPasswordConfirmation,
  });

  ChangePasswordReq copyWith({
    String? currentPassword,
    String? newPassword,
    String? newPasswordConfirmation,
  }) =>
      ChangePasswordReq(
        currentPassword: currentPassword ?? this.currentPassword,
        newPassword: newPassword ?? this.newPassword,
        newPasswordConfirmation: newPasswordConfirmation ?? this.newPasswordConfirmation,
      );

  factory ChangePasswordReq.fromJson(Map<String, dynamic> json) => ChangePasswordReq(
        currentPassword: json["current_password"],
        newPassword: json["new_password"],
        newPasswordConfirmation: json["new_password_confirmation"],
      );

  Map<String, dynamic> toJson() => {
        "current_password": currentPassword,
        "new_password": newPassword,
        "new_password_confirmation": newPasswordConfirmation,
      };
}
