// To parse this JSON data, do
//
//     final subscriptionsPlanDto = subscriptionsPlanDtoFromJson(jsonString);

import 'dart:convert';

SubscriptionsPlanDto subscriptionsPlanDtoFromJson(String str) =>
    SubscriptionsPlanDto.fromJson(json.decode(str));

String subscriptionsPlanDtoToJson(SubscriptionsPlanDto data) => json.encode(data.toJson());

class SubscriptionsPlanDto {
  final String? id;
  final String? name;
  final String? planCode;
  final String? interval;
  final String? amount;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubscriptionsPlanDto({
    this.id,
    this.name,
    this.planCode,
    this.interval,
    this.amount,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory SubscriptionsPlanDto.fromJson(Map<String, dynamic> json) => SubscriptionsPlanDto(
        id: json["id"],
        name: json["name"],
        planCode: json["plan_code"],
        interval: json["interval"],
        amount: json["amount"],
        isActive: json["is_active"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "plan_code": planCode,
        "interval": interval,
        "amount": amount,
        "is_active": isActive,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
