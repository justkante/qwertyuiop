import 'user_dto.dart';

class ReviewDto {
  final String? id;
  final String? reviewerId;
  final String? revieweeId;
  final String? bookingId;
  final double? rating;
  final String? comment;
  final DateTime? createdAt;
  final UserDto? reviewer;

  ReviewDto({
    this.id,
    this.reviewerId,
    this.revieweeId,
    this.bookingId,
    this.rating,
    this.comment,
    this.createdAt,
    this.reviewer,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) => ReviewDto(
        id: json["id"],
        reviewerId: json["reviewer_id"],
        revieweeId: json["reviewee_id"],
        bookingId: json["booking_id"],
        rating: json["rating"] == null ? null : double.tryParse(json["rating"].toString()),
        comment: json["comment"] ?? json["review"], // Backend uses 'review' field in BookingReview
        createdAt: json["created_at"] == null ? null : DateTime.tryParse(json["created_at"].toString()),
        reviewer: json["reviewer"] == null ? (json["user"] == null ? null : UserDto.fromJson(json["user"])) : UserDto.fromJson(json["reviewer"]),
      );
}
