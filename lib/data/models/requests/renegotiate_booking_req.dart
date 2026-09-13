// To parse this JSON data, do
//
//     final renegotiateBookingReq = renegotiateBookingReqFromJson(jsonString);

import 'dart:convert';

RenegotiateBookingReq renegotiateBookingReqFromJson(String str) =>
    RenegotiateBookingReq.fromJson(json.decode(str));

String renegotiateBookingReqToJson(RenegotiateBookingReq data) => json.encode(data.toJson());

class RenegotiateBookingReq {
  final num? newPrice;
  final List<NewDeliverablePrice>? newDeliverablePrices;

  final String? reasonId;
  final String? details;

  RenegotiateBookingReq({
    this.newPrice,
    this.reasonId,
    this.details,
    this.newDeliverablePrices,
  });

  RenegotiateBookingReq copyWith({
    num? newPrice,
    String? reasonId,
    String? details,
    List<NewDeliverablePrice>? newDeliverablePrices,
  }) =>
      RenegotiateBookingReq(
        newPrice: newPrice ?? this.newPrice,
        reasonId: reasonId ?? this.reasonId,
        details: details ?? this.details,
        newDeliverablePrices: newDeliverablePrices ?? this.newDeliverablePrices,
      );

  factory RenegotiateBookingReq.fromJson(Map<String, dynamic> json) => RenegotiateBookingReq(
        newPrice: json["new_price"],
        reasonId: json["reason_id"],
        details: json["details"],
        newDeliverablePrices: json["new_deliverable_prices"] == null
            ? []
            : List<NewDeliverablePrice>.from(
                json["new_deliverable_prices"]!.map((x) => NewDeliverablePrice.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        if (newPrice != null) "new_price": newPrice,
        "reason_id": reasonId,
        "details": details,
        if (newDeliverablePrices != null)
          "new_deliverable_prices":
              List<dynamic>.from(newDeliverablePrices!.map((x) => x.toJson())),
      };
}

class NewDeliverablePrice {
  final String? deliverableId;
  final num? newPrice;

  NewDeliverablePrice({
    this.deliverableId,
    this.newPrice,
  });

  NewDeliverablePrice copyWith({
    String? deliverableId,
    num? newPrice,
  }) =>
      NewDeliverablePrice(
        deliverableId: deliverableId ?? this.deliverableId,
        newPrice: newPrice ?? this.newPrice,
      );

  factory NewDeliverablePrice.fromJson(Map<String, dynamic> json) => NewDeliverablePrice(
        deliverableId: json["deliverable_id"],
        newPrice: json["new_price"],
      );

  Map<String, dynamic> toJson() => {
        "deliverable_id": deliverableId,
        "new_price": newPrice,
      };
}
