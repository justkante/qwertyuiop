// To parse this JSON data, do
//
//     final deliveryBasedBookCreatorReq = deliveryBasedBookCreatorReqFromJson(jsonString);

import 'dart:convert';

BookCreatorReq deliveryBasedBookCreatorReqFromJson(String str) =>
    BookCreatorReq.fromJson(json.decode(str));

String deliveryBasedBookCreatorReqToJson(BookCreatorReq data) => json.encode(data.toJson());

class BookCreatorReq {
  final String? creatorName;
  final String? creatorId;
  final String? creatorCategory;
  final String? creatorCategoryId;
  final String? bookingType;
  final String? workMode;
  final String? jobDescription;
  final String? startTime;
  final DateTime? startDate;
  final String? duration;
  final dynamic location;
  final num? price;
  final List<Deliverable>? deliverables;

  BookCreatorReq({
    this.creatorName,
    this.creatorId,
    this.creatorCategory,
    this.creatorCategoryId,
    this.bookingType,
    this.workMode,
    this.jobDescription,
    this.startTime,
    this.startDate,
    this.duration,
    this.location,
    this.price,
    this.deliverables,
  });

  BookCreatorReq copyWith({
    String? creatorName,
    String? creatorId,
    String? creatorCategory,
    String? creatorCategoryId,
    String? bookingType,
    String? workMode,
    String? jobDescription,
    String? startTime,
    DateTime? startDate,
    String? duration,
    dynamic location,
    num? price,
    List<Deliverable>? deliverables,
  }) =>
      BookCreatorReq(
        creatorName: creatorName ?? this.creatorName,
        creatorId: creatorId ?? this.creatorId,
        creatorCategory: creatorCategory ?? this.creatorCategory,
        creatorCategoryId: creatorCategoryId ?? this.creatorCategoryId,
        bookingType: bookingType ?? this.bookingType,
        workMode: workMode ?? this.workMode,
        jobDescription: jobDescription ?? this.jobDescription,
        startTime: startTime ?? this.startTime,
        startDate: startDate ?? this.startDate,
        duration: duration ?? this.duration,
        location: location ?? this.location,
        price: price ?? this.price,
        deliverables: deliverables ?? this.deliverables,
      );

  factory BookCreatorReq.fromJson(Map<String, dynamic> json) => BookCreatorReq(
        creatorId: json["creator_id"],
        creatorCategoryId: json["creator_category_id"],
        workMode: json["work_mode"],
        bookingType: json["booking_type"],
        jobDescription: json["job_description"],
        startTime: json["start_time"],
        startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
        duration: json["duration"],
        location: json["location"],
        price: json["price"],
        deliverables: json["deliverables"] == null
            ? []
            : List<Deliverable>.from(json["deliverables"]!.map((x) => Deliverable.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "creator_id": creatorId,
        "category_id": creatorCategoryId,
        "booking_type": bookingType,
        if (workMode != null && workMode != "") "work_mode": workMode,
        if (jobDescription != null && jobDescription != "") "job_description": jobDescription,
        if (startTime != null && startTime != "") "start_time": startTime,
        if (startDate != null && startDate.toString() != "")
          "start_date":
              "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        if (duration != null && duration != "") "duration": duration,
        if (location != null && location != "") "location": location,
        if (price != null) "price": price,
        if (deliverables != null)
          "deliverables":
              deliverables == null ? [] : List<dynamic>.from(deliverables!.map((x) => x.toJson())),
      };
}

class Deliverable {
  final String? description;
  final num? price;

  Deliverable({
    this.description,
    this.price,
  });

  Deliverable copyWith({
    String? description,
    num? price,
  }) =>
      Deliverable(
        description: description ?? this.description,
        price: price ?? this.price,
      );

  factory Deliverable.fromJson(Map<String, dynamic> json) => Deliverable(
        description: json["description"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "price": price,
      };
}
