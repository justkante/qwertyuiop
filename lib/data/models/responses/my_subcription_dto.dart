// To parse this JSON data, do
//
//     final mySubscriptionDto = mySubscriptionDtoFromJson(jsonString);

import 'dart:convert';

MySubscriptionDto mySubscriptionDtoFromJson(String str) =>
    MySubscriptionDto.fromJson(json.decode(str));

String mySubscriptionDtoToJson(MySubscriptionDto data) => json.encode(data.toJson());

class MySubscriptionDto {
  final bool? success;
  final Data? data;
  final bool? hasSubscription;
  final bool? isActive;

  MySubscriptionDto({
    this.success,
    this.data,
    this.hasSubscription,
    this.isActive,
  });

  factory MySubscriptionDto.fromJson(Map<String, dynamic> json) => MySubscriptionDto(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        hasSubscription: json["has_subscription"],
        isActive: json["is_active"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "has_subscription": hasSubscription,
        "is_active": isActive,
      };
}

class Data {
  final String? id;
  final String? creatorId;
  final String? subscriptionPlanId;
  final dynamic subscriptionCode;
  final dynamic emailToken;
  final String? amount;
  final String? status;
  final String? paymentReference;
  final String? paystackReference;
  final bool? autoRenew;
  final DateTime? nextPaymentDate;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final bool? cancelledAtPeriodEnd;
  final dynamic cancelledAt;
  final DateTime? createdAt;
  final Plan? plan;

  Data({
    this.id,
    this.creatorId,
    this.subscriptionPlanId,
    this.subscriptionCode,
    this.emailToken,
    this.amount,
    this.status,
    this.paymentReference,
    this.paystackReference,
    this.autoRenew,
    this.nextPaymentDate,
    this.startsAt,
    this.expiresAt,
    this.cancelledAtPeriodEnd,
    this.cancelledAt,
    this.createdAt,
    this.plan,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        creatorId: json["creator_id"],
        subscriptionPlanId: json["subscription_plan_id"],
        subscriptionCode: json["subscription_code"],
        emailToken: json["email_token"],
        amount: json["amount"],
        status: json["status"],
        paymentReference: json["payment_reference"],
        paystackReference: json["paystack_reference"],
        autoRenew: json["auto_renew"],
        nextPaymentDate:
            json["next_payment_date"] == null ? null : DateTime.parse(json["next_payment_date"]),
        startsAt: json["starts_at"] == null ? null : DateTime.parse(json["starts_at"]),
        expiresAt: json["expires_at"] == null ? null : DateTime.parse(json["expires_at"]),
        cancelledAtPeriodEnd: json["cancelled_at_period_end"],
        cancelledAt: json["cancelled_at"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        plan: json["plan"] == null ? null : Plan.fromJson(json["plan"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "creator_id": creatorId,
        "subscription_plan_id": subscriptionPlanId,
        "subscription_code": subscriptionCode,
        "email_token": emailToken,
        "amount": amount,
        "status": status,
        "payment_reference": paymentReference,
        "paystack_reference": paystackReference,
        "auto_renew": autoRenew,
        "next_payment_date": nextPaymentDate?.toIso8601String(),
        "starts_at": startsAt?.toIso8601String(),
        "expires_at": expiresAt?.toIso8601String(),
        "cancelled_at_period_end": cancelledAtPeriodEnd,
        "cancelled_at": cancelledAt,
        "created_at": createdAt?.toIso8601String(),
        "plan": plan?.toJson(),
      };
}

class Plan {
  final String? id;
  final String? name;
  final String? planCode;
  final String? interval;
  final String? amount;
  final bool? isActive;
  final Prices? prices;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Plan({
    this.id,
    this.name,
    this.planCode,
    this.interval,
    this.amount,
    this.prices,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json["id"],
        name: json["name"],
        planCode: json["plan_code"],
        interval: json["interval"],
        amount: json["amount"],
        prices: json["prices"] != null ? Prices.fromJson(json["prices"]) : null,
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
        "prices": prices,
        "is_active": isActive,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class Prices {
  final Gbp? gbp;
  final Ngn? ngn;

  Prices({
    this.gbp,
    this.ngn,
  });

  factory Prices.fromJson(Map<String, dynamic> json) => Prices(
        gbp: json["GBP"] == null ? null : Gbp.fromJson(json["GBP"]),
        ngn: json["NGN"] == null ? null : Ngn.fromJson(json["NGN"]),
      );

  Map<String, dynamic> toJson() => {
        "GBP": gbp?.toJson(),
        "NGN": ngn?.toJson(),
      };
}

class Gbp {
  final num? amount;
  final String? gateway;
  final String? stripePriceId;

  Gbp({
    this.amount,
    this.gateway,
    this.stripePriceId,
  });

  factory Gbp.fromJson(Map<String, dynamic> json) => Gbp(
        amount: json["amount"],
        gateway: json["gateway"],
        stripePriceId: json["stripe_price_id"],
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "gateway": gateway,
        "stripe_price_id": stripePriceId,
      };
}

class Ngn {
  final num? amount;
  final String? gateway;
  final String? planCode;

  Ngn({
    this.amount,
    this.gateway,
    this.planCode,
  });

  factory Ngn.fromJson(Map<String, dynamic> json) => Ngn(
        amount: json["amount"],
        gateway: json["gateway"],
        planCode: json["plan_code"],
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "gateway": gateway,
        "plan_code": planCode,
      };
}
