// To parse this JSON data, do
//
//     final fundWalletDto = fundWalletDtoFromJson(jsonString);

import 'dart:convert';

FundWalletDto fundWalletDtoFromJson(String str) => FundWalletDto.fromJson(json.decode(str));

String fundWalletDtoToJson(FundWalletDto data) => json.encode(data.toJson());

class FundWalletDto {
  final String? authorizationUrl;
  final String? accessCode;
  final String? reference;
  final String? transactionId;
  final String? clientSecret;
  final String? stripePaymentIntentId;
  final String? gateway;

  FundWalletDto({
    this.authorizationUrl,
    this.accessCode,
    this.reference,
    this.transactionId,
    this.clientSecret,
    this.stripePaymentIntentId,
    this.gateway,
  });

  factory FundWalletDto.fromJson(Map<String, dynamic> json) => FundWalletDto(
        authorizationUrl: json["authorization_url"],
        accessCode: json["access_code"],
        reference: json["reference"],
        transactionId: json["transaction_id"],
        clientSecret: json["client_secret"],
        stripePaymentIntentId: json["stripe_payment_intent_id"],
        gateway: json["gateway"],
      );

  Map<String, dynamic> toJson() => {
        "authorization_url": authorizationUrl,
        "access_code": accessCode,
        "reference": reference,
        "transaction_id": transactionId,
        "client_secret": clientSecret,
        "stripe_payment_intent_id": stripePaymentIntentId,
        "gateway": gateway,
      };
}
