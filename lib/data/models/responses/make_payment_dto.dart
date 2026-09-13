// To parse this JSON data, do
//
//     final makePaymentDto = makePaymentDtoFromJson(jsonString);

import 'dart:convert';

MakePaymentDto makePaymentDtoFromJson(String str) => MakePaymentDto.fromJson(json.decode(str));

String makePaymentDtoToJson(MakePaymentDto data) => json.encode(data.toJson());

class MakePaymentDto {
  final String? paymentReference;
  final String? authorizationUrl;
  final String? accessCode;
  final num? amount;
  final String? clientSecret;
  final String? stripePaymentIntentId;
  final String? gateway;
  final String? paymentId;
  final String? paymentMethod;
  final String? currency;

  MakePaymentDto({
    this.paymentReference,
    this.authorizationUrl,
    this.accessCode,
    this.amount,
    this.clientSecret,
    this.stripePaymentIntentId,
    this.gateway,
    this.paymentId,
    this.paymentMethod,
    this.currency,
  });

  factory MakePaymentDto.fromJson(Map<String, dynamic> json) => MakePaymentDto(
        paymentReference: json["payment_reference"],
        authorizationUrl: json["authorization_url"],
        accessCode: json["access_code"],
        amount: json["amount"],
        clientSecret: json["client_secret"],
        stripePaymentIntentId: json["stripe_payment_intent_id"],
        gateway: json["gateway"],
        paymentId: json["payment_id"],
        paymentMethod: json["payment_method"],
        currency: json["currency"],
      );

  Map<String, dynamic> toJson() => {
        "payment_reference": paymentReference,
        "authorization_url": authorizationUrl,
        "access_code": accessCode,
        "amount": amount,
        "client_secret": clientSecret,
        "stripe_payment_intent_id": stripePaymentIntentId,
        "gateway": gateway,
        "payment_id": paymentId,
        "payment_method": paymentMethod,
        "currency": currency,
      };
}
