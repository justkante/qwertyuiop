// To parse this JSON data, do
//
//     final pendingReviewItemDto = pendingReviewItemDtoFromJson(jsonString);

import 'dart:convert';

PendingReviewItemDto pendingReviewItemDtoFromJson(String str) =>
    PendingReviewItemDto.fromJson(json.decode(str));

String pendingReviewItemDtoToJson(PendingReviewItemDto data) => json.encode(data.toJson());

class PendingReviewItemDto {
  final String? bookingId;
  final String? jobDescription;
  final String? bookingType;
  final int? finalPrice;
  final String? currency;
  final DateTime? completedAt;
  final Recruiter? recruiter;

  PendingReviewItemDto({
    this.bookingId,
    this.jobDescription,
    this.bookingType,
    this.finalPrice,
    this.currency,
    this.completedAt,
    this.recruiter,
  });

  factory PendingReviewItemDto.fromJson(Map<String, dynamic> json) => PendingReviewItemDto(
        bookingId: json["booking_id"],
        jobDescription: json["job_description"],
        bookingType: json["booking_type"],
        finalPrice: json["final_price"],
        currency: json["currency"],
        completedAt: json["completed_at"] == null ? null : DateTime.parse(json["completed_at"]),
        recruiter: json["recruiter"] == null ? null : Recruiter.fromJson(json["recruiter"]),
      );

  Map<String, dynamic> toJson() => {
        "booking_id": bookingId,
        "job_description": jobDescription,
        "booking_type": bookingType,
        "final_price": finalPrice,
        "currency": currency,
        "completed_at": completedAt?.toIso8601String(),
        "recruiter": recruiter?.toJson(),
      };
}

class Recruiter {
  final String? id;
  final String? name;
  final String? email;
  final dynamic profileImage;

  Recruiter({
    this.id,
    this.name,
    this.email,
    this.profileImage,
  });

  factory Recruiter.fromJson(Map<String, dynamic> json) => Recruiter(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        profileImage: json["profile_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "profile_image": profileImage,
      };
}
