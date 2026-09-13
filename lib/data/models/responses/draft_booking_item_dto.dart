// To parse this JSON data, do
//
//     final bookingItemDto = bookingItemDtoFromJson(jsonString);

import 'dart:convert';

import 'package:creatify_mobile/data/models/requests/book_creator_req.dart';
import 'package:creatify_mobile/data/models/responses/booking_item_dto.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart'
    show ExchangeRateInfo;

DraftingBookingItemDto bookingItemDtoFromJson(String str) =>
    DraftingBookingItemDto.fromJson(json.decode(str));

String bookingItemDtoToJson(DraftingBookingItemDto data) => json.encode(data.toJson());

class DraftingBookingItemDto {
  final String? id;
  final String? bookingType;
  final String? jobDescription;
  final Creator? creator;
  final DateTime? startDate;
  final String? startTime;
  final String? duration;
  final String? location;
  final String? workMode;
  final String? offeredPrice;
  final Service? category;
  final List<Deliverable>? deliverables;
  final String? primaryCurrency;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ExchangeRateInfo? exchangeRateInfo;

  DraftingBookingItemDto({
    this.id,
    this.bookingType,
    this.jobDescription,
    this.startDate,
    this.startTime,
    this.duration,
    this.location,
    this.workMode,
    this.offeredPrice,
    this.creator,
    this.category,
    this.deliverables,
    this.createdAt,
    this.updatedAt,
    this.primaryCurrency,
    this.exchangeRateInfo,
  });

  factory DraftingBookingItemDto.fromJson(Map<String, dynamic> json) => DraftingBookingItemDto(
        id: json["id"],
        bookingType: json["booking_type"],
        jobDescription: json["job_description"],
        startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
        startTime: json["start_time"],
        duration: json["duration"],
        location: json["location"],
        workMode: json["work_mode"],
        offeredPrice: json["price"],
        creator: json["creator"] == null ? null : Creator.fromJson(json["creator"]),
        category: json["category"] == null ? null : Service.fromJson(json["category"]),
        deliverables: json["deliverables"] == null
            ? []
            : List<Deliverable>.from(json["deliverables"]!.map((x) => Deliverable.fromJson(x))),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        primaryCurrency: json["primary_currency"],
        exchangeRateInfo: json["exchange_rate_info"] == null
            ? null
            : ExchangeRateInfo.fromJson(json["exchange_rate_info"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "booking_type": bookingType,
        "job_description": jobDescription,
        "start_date":
            "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        "start_time": startTime,
        "duration": duration,
        "location": location,
        "work_mode": workMode,
        "price": offeredPrice,
        "creator": creator?.toJson(),
        "category": category?.toJson(),
        "deliverables":
            deliverables == null ? [] : List<dynamic>.from(deliverables!.map((x) => x.toJson())),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "primary_currency": primaryCurrency,
        "exchange_rate_info": exchangeRateInfo?.toJson(),
      };
}
