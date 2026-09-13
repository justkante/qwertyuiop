// To parse this JSON data, do
//
//     final changeWalletPinReq = changeWalletPinReqFromJson(jsonString);

import 'dart:convert';

ChangeWalletPinReq changeWalletPinReqFromJson(String str) =>
    ChangeWalletPinReq.fromJson(json.decode(str));

String changeWalletPinReqToJson(ChangeWalletPinReq data) => json.encode(data.toJson());

class ChangeWalletPinReq {
  final String? oldPin;
  final String? newPin;
  final String? confirmNewPin;

  ChangeWalletPinReq({
    this.oldPin,
    this.newPin,
    this.confirmNewPin,
  });

  ChangeWalletPinReq copyWith({
    String? oldPin,
    String? newPin,
    String? confirmNewPin,
  }) =>
      ChangeWalletPinReq(
        oldPin: oldPin ?? this.oldPin,
        newPin: newPin ?? this.newPin,
        confirmNewPin: confirmNewPin ?? this.confirmNewPin,
      );

  factory ChangeWalletPinReq.fromJson(Map<String, dynamic> json) => ChangeWalletPinReq(
        oldPin: json["old_pin"],
        newPin: json["new_pin"],
        confirmNewPin: json["confirm_new_pin"],
      );

  Map<String, dynamic> toJson() => {
        "old_pin": oldPin,
        "new_pin": newPin,
        "confirm_new_pin": confirmNewPin,
      };
}
