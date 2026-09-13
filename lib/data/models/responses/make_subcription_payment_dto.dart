// To parse this JSON data, do
//
//     final makeSubcriptionPaymentDto = makeSubcriptionPaymentDtoFromJson(jsonString);

import 'dart:convert';

MakeSubcriptionPaymentDto makeSubcriptionPaymentDtoFromJson(String str) =>
    MakeSubcriptionPaymentDto.fromJson(json.decode(str));

String makeSubcriptionPaymentDtoToJson(MakeSubcriptionPaymentDto data) =>
    json.encode(data.toJson());

class MakeSubcriptionPaymentDto {
  final String? subscriptionId;
  final String? paymentReference;
  final String? authorizationUrl;
  final String? accessCode;
  final String? amount;
  final String? planName;
  final String? interval;

  MakeSubcriptionPaymentDto({
    this.subscriptionId,
    this.paymentReference,
    this.authorizationUrl,
    this.accessCode,
    this.amount,
    this.planName,
    this.interval,
  });

  factory MakeSubcriptionPaymentDto.fromJson(Map<String, dynamic> json) =>
      MakeSubcriptionPaymentDto(
        subscriptionId: json["subscription_id"],
        paymentReference: json["payment_reference"],
        authorizationUrl: json["authorization_url"],
        accessCode: json["access_code"],
        amount: json["amount"],
        planName: json["plan_name"],
        interval: json["interval"],
      );

  Map<String, dynamic> toJson() => {
        "subscription_id": subscriptionId,
        "payment_reference": paymentReference,
        "authorization_url": authorizationUrl,
        "access_code": accessCode,
        "amount": amount,
        "plan_name": planName,
        "interval": interval,
      };
}
