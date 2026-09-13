// To parse this JSON data, do
//
//     final createWalletPinReq = createWalletPinReqFromJson(jsonString);

import 'dart:convert';

CreateWalletPinReq createWalletPinReqFromJson(String str) =>
    CreateWalletPinReq.fromJson(json.decode(str));

String createWalletPinReqToJson(CreateWalletPinReq data) => json.encode(data.toJson());

class CreateWalletPinReq {
  final String? pin;
  final String? confirmPin;

  CreateWalletPinReq({
    this.pin,
    this.confirmPin,
  });

  CreateWalletPinReq copyWith({
    String? pin,
    String? confirmPin,
  }) =>
      CreateWalletPinReq(
        pin: pin ?? this.pin,
        confirmPin: confirmPin ?? this.confirmPin,
      );

  factory CreateWalletPinReq.fromJson(Map<String, dynamic> json) => CreateWalletPinReq(
        pin: json["pin"],
        confirmPin: json["confirm_pin"],
      );

  Map<String, dynamic> toJson() => {
        "pin": pin,
        "confirm_pin": confirmPin,
      };
}
