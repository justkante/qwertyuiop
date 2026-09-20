import 'dart:convert';

RecruiterProfileDto recruiterProfileDtoFromJson(String str) =>
    RecruiterProfileDto.fromJson(json.decode(str));

String recruiterProfileDtoToJson(RecruiterProfileDto data) => json.encode(data.toJson());

class RecruiterProfileDto {
  final String? id;
  final String? name;
  final String? email;
  final String? profileImage;
  final String? lastSeenAt;
  final bool? isPremium;
  final RatingsAndReviews? ratingsAndReviews;
  final Analytics? analytics;

  RecruiterProfileDto({
    this.id,
    this.name,
    this.profileImage,
    this.email,
    this.ratingsAndReviews,
    this.lastSeenAt,
    this.analytics,
    this.isPremium,
  });

  String get initials {
    if (name == null || name!.isEmpty) {
      return "";
    }
    final names = name!.split(" ");
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    } else {
      return (names[0][0] + names[1][0]).toUpperCase();
    }
  }

  RecruiterProfileDto copyWith({
    String? id,
    String? name,
    String? profileImage,
    String? lastSeenAt,
    bool? isPremium,
    RatingsAndReviews? ratingsAndReviews,
    Analytics? analytics,
    String? email,
  }) =>
      RecruiterProfileDto(
        id: id ?? this.id,
        name: name ?? this.name,
        profileImage: profileImage ?? this.profileImage,
        email: email ?? this.email,
        isPremium: isPremium ?? this.isPremium,
        ratingsAndReviews: ratingsAndReviews ?? this.ratingsAndReviews,
        analytics: analytics ?? this.analytics,
        lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      );

  factory RecruiterProfileDto.fromJson(Map<String, dynamic> json) => RecruiterProfileDto(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        profileImage: json["profile_image"],
        isPremium: json["is_premium"],
        ratingsAndReviews:
            json["reviews"] == null ? null : RatingsAndReviews.fromJson(json["reviews"]),
        analytics: json["analytics"] == null ? null : Analytics.fromJson(json["analytics"]),
        lastSeenAt: json["last_seen_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "profile_image": profileImage,
        "is_premium": isPremium,
        "reviews": ratingsAndReviews?.toJson(),
        "analytics": analytics?.toJson(),
        "last_seen_at": lastSeenAt,
      };
}

class Availability {
  final DateTime? unavailableDate;
  final bool? isFullDay;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? reason;

  Availability({
    this.unavailableDate,
    this.isFullDay,
    this.startTime,
    this.endTime,
    this.reason,
  });

  Availability copyWith({
    DateTime? unavailableDate,
    bool? isFullDay,
    DateTime? startTime,
    DateTime? endTime,
    String? reason,
  }) =>
      Availability(
        unavailableDate: unavailableDate ?? this.unavailableDate,
        isFullDay: isFullDay ?? this.isFullDay,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        reason: reason ?? this.reason,
      );

  factory Availability.fromJson(Map<String, dynamic> json) => Availability(
        unavailableDate:
            json["unavailable_date"] == null ? null : DateTime.parse(json["unavailable_date"]),
        isFullDay: json["is_full_day"],
        startTime: json["start_time"] == null ? null : DateTime.parse(json["start_time"]),
        endTime: json["end_time"] == null ? null : DateTime.parse(json["end_time"]),
        reason: json["reason"],
      );

  Map<String, dynamic> toJson() => {
        "unavailable_date":
            "${unavailableDate!.year.toString().padLeft(4, '0')}-${unavailableDate!.month.toString().padLeft(2, '0')}-${unavailableDate!.day.toString().padLeft(2, '0')}",
        "is_full_day": isFullDay,
        "start_time": startTime?.toIso8601String(),
        "end_time": endTime?.toIso8601String(),
        "reason": reason,
      };
}

class Category {
  final String? id;
  final String? name;
  final List<Service>? services;

  Category({
    this.id,
    this.name,
    this.services,
  });

  Category copyWith({
    String? id,
    String? name,
    List<Service>? services,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        services: services ?? this.services,
      );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        services: json["services"] == null
            ? []
            : List<Service>.from(json["services"]!.map((x) => Service.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "services": services == null ? [] : List<dynamic>.from(services!.map((x) => x.toJson())),
      };
}

class Service {
  final String? serviceId;
  final String? serviceName;
  final num? price;
  final String? pricingType;

  Service({
    this.serviceId,
    this.serviceName,
    this.price,
    this.pricingType,
  });

  Service copyWith({
    String? serviceId,
    String? serviceName,
    num? price,
    String? pricingType,
  }) =>
      Service(
        serviceId: serviceId ?? this.serviceId,
        serviceName: serviceName ?? this.serviceName,
        price: price ?? this.price,
        pricingType: pricingType ?? this.pricingType,
      );

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        serviceId: json["service_id"],
        serviceName: json["service_name"],
        price: json["price"],
        pricingType: json["pricing_type"],
      );

  Map<String, dynamic> toJson() => {
        "service_id": serviceId,
        "service_name": serviceName,
        "price": price,
        "pricing_type": pricingType,
      };
}

class Portfolio {
  final String? id;
  final String? mediaType;
  final String? fileName;
  final String? filePath;
  final double? fileSizeMb;
  final int? sortOrder;

  Portfolio({
    this.id,
    this.mediaType,
    this.fileName,
    this.filePath,
    this.fileSizeMb,
    this.sortOrder,
  });

  Portfolio copyWith({
    String? id,
    String? mediaType,
    String? fileName,
    String? filePath,
    double? fileSizeMb,
    int? sortOrder,
  }) =>
      Portfolio(
        id: id ?? this.id,
        mediaType: mediaType ?? this.mediaType,
        fileName: fileName ?? this.fileName,
        filePath: filePath ?? this.filePath,
        fileSizeMb: fileSizeMb ?? this.fileSizeMb,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  factory Portfolio.fromJson(Map<String, dynamic> json) => Portfolio(
        id: json["id"],
        mediaType: json["media_type"],
        fileName: json["file_name"],
        filePath: json["file_path"],
        fileSizeMb: json["file_size_mb"]?.toDouble(),
        sortOrder: json["sort_order"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "media_type": mediaType,
        "file_name": fileName,
        "file_path": filePath,
        "file_size_mb": fileSizeMb,
        "sort_order": sortOrder,
      };
}

class RatingsAndReviews {
  final num? averageRating;
  final int? totalReviews;
  final RatingBreakdown? ratingBreakdown;
  final List<Review>? reviews;

  RatingsAndReviews({
    this.averageRating,
    this.totalReviews,
    this.ratingBreakdown,
    this.reviews,
  });

  RatingsAndReviews copyWith({
    num? averageRating,
    int? totalReviews,
    RatingBreakdown? ratingBreakdown,
    List<Review>? reviews,
  }) =>
      RatingsAndReviews(
        averageRating: averageRating ?? this.averageRating,
        totalReviews: totalReviews ?? this.totalReviews,
        ratingBreakdown: ratingBreakdown ?? this.ratingBreakdown,
        reviews: reviews ?? this.reviews,
      );

  factory RatingsAndReviews.fromJson(Map<String, dynamic> json) => RatingsAndReviews(
        averageRating: json["average_rating"],
        totalReviews: json["total_reviews"],
        ratingBreakdown: json["rating_breakdown"] == null
            ? null
            : RatingBreakdown.fromJson(json["rating_breakdown"]),
        reviews: json["reviews"] == null
            ? []
            : List<Review>.from(json["reviews"]!.map((x) => Review.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "average_rating": averageRating,
        "total_reviews": totalReviews,
        "rating_breakdown": ratingBreakdown?.toJson(),
        "reviews": reviews == null ? [] : List<dynamic>.from(reviews!.map((x) => x.toJson())),
      };
}

class RatingBreakdown {
  final int? the5Star;
  final int? the4Star;
  final int? the3Star;
  final int? the2Star;
  final int? the1Star;

  RatingBreakdown({
    this.the5Star,
    this.the4Star,
    this.the3Star,
    this.the2Star,
    this.the1Star,
  });

  RatingBreakdown copyWith({
    int? the5Star,
    int? the4Star,
    int? the3Star,
    int? the2Star,
    int? the1Star,
  }) =>
      RatingBreakdown(
        the5Star: the5Star ?? this.the5Star,
        the4Star: the4Star ?? this.the4Star,
        the3Star: the3Star ?? this.the3Star,
        the2Star: the2Star ?? this.the2Star,
        the1Star: the1Star ?? this.the1Star,
      );

  factory RatingBreakdown.fromJson(Map<String, dynamic> json) => RatingBreakdown(
        the5Star: json["5_star"],
        the4Star: json["4_star"],
        the3Star: json["3_star"],
        the2Star: json["2_star"],
        the1Star: json["1_star"],
      );

  Map<String, dynamic> toJson() => {
        "5_star": the5Star,
        "4_star": the4Star,
        "3_star": the3Star,
        "2_star": the2Star,
        "1_star": the1Star,
      };
}

class Review {
  final String? id;
  final num? rating;
  final String? review;
  final String? reviewerName;
  final DateTime? createdAt;

  Review({
    this.id,
    this.rating,
    this.review,
    this.reviewerName,
    this.createdAt,
  });

  Review copyWith({
    String? id,
    num? rating,
    String? review,
    String? reviewerName,
    DateTime? createdAt,
  }) =>
      Review(
        id: id ?? this.id,
        rating: rating ?? this.rating,
        review: review ?? this.review,
        reviewerName: reviewerName ?? this.reviewerName,
        createdAt: createdAt ?? this.createdAt,
      );

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        rating: json["rating"],
        review: json["review"],
        reviewerName: json["reviewer_name"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "rating": rating,
        "review": review,
        "reviewer_name": reviewerName,
        "created_at":
            "${createdAt!.year.toString().padLeft(4, '0')}-${createdAt!.month.toString().padLeft(2, '0')}-${createdAt!.day.toString().padLeft(2, '0')}",
      };
}

class Analytics {
  final int? totalBookings;
  final int? activeBookings;
  final num? cancellationRate;
  final num? repeatHireRate;
  final num? averageResponseTime;
  final DateTime? memberSince;

  Analytics({
    this.totalBookings,
    this.cancellationRate,
    this.activeBookings,
    this.repeatHireRate,
    this.averageResponseTime,
    this.memberSince,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) => Analytics(
        totalBookings: json["total_bookings"],
        cancellationRate: json["cancellation_rate"]?.toDouble(),
        activeBookings: json["active_bookings"],
        repeatHireRate: json["repeat_hire_rate"],
        averageResponseTime: json["average_response_time"]?.toDouble(),
        memberSince: json["member_since"] == null ? null : DateTime.parse(json["member_since"]),
      );

  Map<String, dynamic> toJson() => {
        "total_bookings": totalBookings,
        "cancellation_rate": cancellationRate,
        "active_bookings": activeBookings,
        "repeat_hire_rate": repeatHireRate,
        "average_response_time": averageResponseTime,
        "member_since":
            "${memberSince!.year.toString().padLeft(4, '0')}-${memberSince!.month.toString().padLeft(2, '0')}-${memberSince!.day.toString().padLeft(2, '0')}",
      };
}
