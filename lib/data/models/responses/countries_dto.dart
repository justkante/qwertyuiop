// To parse this JSON data, do
//
//     final countriesDto = countriesDtoFromJson(jsonString);

import 'dart:convert';

CountriesItemDto countriesDtoFromJson(String str) => CountriesItemDto.fromJson(json.decode(str));

String countriesDtoToJson(CountriesItemDto data) => json.encode(data.toJson());

class CountriesItemDto {
  final String? id;
  final String? code;
  final String? name;
  final String? currency;
  final String? currencySymbol;
  final String? paymentGateway;
  final String? flagEmoji;
  final String? region;

  CountriesItemDto({
    this.id,
    this.code,
    this.name,
    this.currency,
    this.currencySymbol,
    this.paymentGateway,
    this.flagEmoji,
    this.region,
  });

  factory CountriesItemDto.fromJson(Map<String, dynamic> json) => CountriesItemDto(
        id: json["id"],
        code: json["code"],
        name: json["name"],
        currency: json["currency"],
        currencySymbol: json["currency_symbol"],
        paymentGateway: json["payment_gateway"],
        flagEmoji: json["flag_emoji"],
        region: json["region"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "name": name,
        "currency": currency,
        "currency_symbol": currencySymbol,
        "payment_gateway": paymentGateway,
        "flag_emoji": flagEmoji,
        "region": region,
      };
}
