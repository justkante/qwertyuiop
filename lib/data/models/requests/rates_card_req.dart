// To parse this JSON data, do
//
//     final ratesCardReq = ratesCardReqFromJson(jsonString);

import 'dart:convert';

RatesCardReq ratesCardReqFromJson(String str) => RatesCardReq.fromJson(json.decode(str));

String ratesCardReqToJson(RatesCardReq data) => json.encode(data.toJson());

class RatesCardReq {
  final List<Category>? categories;

  RatesCardReq({
    this.categories,
  });

  RatesCardReq copyWith({
    List<Category>? categories,
  }) =>
      RatesCardReq(
        categories: categories ?? this.categories,
      );

  factory RatesCardReq.fromJson(Map<String, dynamic> json) => RatesCardReq(
        categories: json["categories"] == null
            ? []
            : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categories":
            categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
      };
}

class Category {
  final String? categoryId;
  final String? pricingType;
  final List<Service>? services;

  Category({
    this.categoryId,
    this.pricingType,
    this.services,
  });

  Category copyWith({
    String? categoryId,
    String? pricingType,
    List<Service>? services,
  }) =>
      Category(
        categoryId: categoryId ?? this.categoryId,
        pricingType: pricingType ?? this.pricingType,
        services: services ?? this.services,
      );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        categoryId: json["category_id"],
        pricingType: json["pricing_type"],
        services: json["services"] == null
            ? []
            : List<Service>.from(json["services"]!.map((x) => Service.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "category_id": categoryId,
        "pricing_type": pricingType,
        "services": services == null ? [] : List<dynamic>.from(services!.map((x) => x.toJson())),
      };
}

class Service {
  final String? serviceName;
  final num? price;

  Service({
    this.serviceName,
    this.price,
  });

  Service copyWith({
    String? serviceName,
    int? price,
  }) =>
      Service(
        serviceName: serviceName ?? this.serviceName,
        price: price ?? this.price,
      );

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        serviceName: json["service_name"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "service_name": serviceName,
        "price": price,
      };
}
