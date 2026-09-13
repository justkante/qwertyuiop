// To parse this JSON data, do
//
//     final transactionDto = transactionDtoFromJson(jsonString);

import 'dart:convert';

TransactionDto transactionDtoFromJson(String str) => TransactionDto.fromJson(json.decode(str));

String transactionDtoToJson(TransactionDto data) => json.encode(data.toJson());

class TransactionDto {
  final List<TransactionItemDto>? data;
  final Summary? summary;

  TransactionDto({
    this.data,
    this.summary,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) => TransactionDto(
        data: json["data"] == null
            ? []
            : List<TransactionItemDto>.from(
                json["data"]!.map((x) => TransactionItemDto.fromJson(x))),
        summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "summary": summary?.toJson(),
      };
}

class TransactionItemDto {
  final String? id;
  final String? type;
  final String? category;

  final num? amount;
  final num? fee;
  final num? gatewayFee;
  final num? platformFee;
  final num? penaltyFee;
  final num? netAmount;
  final String? status;
  final String? paymentReference;
  final String? bookingId;
  final OtherParty? otherParty;
  final DateTime? createdAt;
  final DateTime? paidAt;

  TransactionItemDto({
    this.id,
    this.type,
    this.category,
    this.amount,
    this.fee,
    this.gatewayFee,
    this.platformFee,
    this.penaltyFee,
    this.netAmount,
    this.status,
    this.paymentReference,
    this.bookingId,
    this.otherParty,
    this.createdAt,
    this.paidAt,
  });

  factory TransactionItemDto.fromJson(Map<String, dynamic> json) => TransactionItemDto(
        id: json["id"],
        type: json["type"],
        category: json["category"],
        amount: json["amount"],
        fee: json["fee"],
        gatewayFee: json["gateway_fee"],
        platformFee: json["platform_fee"],
        penaltyFee: json["penalty_fee"],
        netAmount: json["net_amount"],
        status: json["status"],
        paymentReference: json["payment_reference"],
        bookingId: json["booking_id"],
        otherParty: json["other_party"] == null ? null : OtherParty.fromJson(json["other_party"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        paidAt: json["paid_at"] == null ? null : DateTime.parse(json["paid_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "direction": category,
        "amount": amount,
        "fee": fee,
        "gateway_fee": gatewayFee,
        "platform_fee": platformFee,
        "penalty_fee": penaltyFee,
        "net_amount": netAmount,
        "status": status,
        "payment_reference": paymentReference,
        "booking_id": bookingId,
        "other_party": otherParty?.toJson(),
        "created_at": createdAt?.toIso8601String(),
        "paid_at": paidAt?.toIso8601String(),
      };
}

class OtherParty {
  final String? id;
  final String? name;
  final String? role;

  OtherParty({
    this.id,
    this.name,
    this.role,
  });

  factory OtherParty.fromJson(Map<String, dynamic> json) => OtherParty(
        id: json["id"],
        name: json["name"],
        role: json["role"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "role": role,
      };
}

class Summary {
  final num? totalIncoming;
  final num? totalOutgoing;
  final num? netBalance;

  Summary({
    this.totalIncoming,
    this.totalOutgoing,
    this.netBalance,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        totalIncoming: json["total_incoming"],
        totalOutgoing: json["total_outgoing"],
        netBalance: json["net_balance"],
      );

  Map<String, dynamic> toJson() => {
        "total_incoming": totalIncoming,
        "total_outgoing": totalOutgoing,
        "net_balance": netBalance,
      };
}
