// To parse this JSON data, do
//
//     final submitReviewReq = submitReviewReqFromJson(jsonString);

import 'dart:convert';

SubmitReviewReq submitReviewReqFromJson(String str) => SubmitReviewReq.fromJson(json.decode(str));

String submitReviewReqToJson(SubmitReviewReq data) => json.encode(data.toJson());

class SubmitReviewReq {
  final int? rating;
  final String? review;

  SubmitReviewReq({
    this.rating,
    this.review,
  });

  SubmitReviewReq copyWith({
    int? rating,
    String? review,
  }) =>
      SubmitReviewReq(
        rating: rating ?? this.rating,
        review: review ?? this.review,
      );

  factory SubmitReviewReq.fromJson(Map<String, dynamic> json) => SubmitReviewReq(
        rating: json["rating"],
        review: json["review"],
      );

  Map<String, dynamic> toJson() => {
        "rating": rating,
        "review": review,
      };
}
