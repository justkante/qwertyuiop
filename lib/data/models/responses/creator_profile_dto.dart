// To parse this JSON data, do
//
//     final creatorProfileDto = creatorProfileDtoFromJson(jsonString);

import 'dart:convert';

import 'package:creatify_mobile/data/models/responses/portfolio_dto.dart';

CreatorProfileDto creatorProfileDtoFromJson(String str) =>
    CreatorProfileDto.fromJson(json.decode(str));

String creatorProfileDtoToJson(CreatorProfileDto data) => json.encode(data.toJson());

class CreatorProfileDto {
  final String? id;
  final String? name;
  final String? profileImage;
  final String? profileId;
  final String? referralCode;
  final bool? isOnline;
  final bool? isFavorited;
  final String? lastSeenAt;
  final String? email;
  final String? status;
  final bool? isPremium;
  final List<Category>? categories;
  final List<PortfolioItem>? portfolio;
  final String? location;
  final String? workMode;
  final bool? availableToTravel;
  final RatingsAndReviews? ratingsAndReviews;
  final String? countryCode;
  final String? primaryCurrency;
  //final List<Availability>? availability;
  final Analytics? analytics;
  final ExchangeRateInfo? exchangeRateInfo;

  CreatorProfileDto({
    this.id,
    this.name,
    this.lastSeenAt,
    this.profileId,
    this.isOnline,
    this.isFavorited,
    this.profileImage,
    this.referralCode,
    this.isPremium,
    this.email,
    this.status,
    this.categories,
    this.portfolio,
    this.location,
    this.workMode,
    this.availableToTravel,
    this.ratingsAndReviews,
    this.countryCode,
    this.primaryCurrency,
    //this.availability,
    this.analytics,
    this.exchangeRateInfo,
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

  CreatorProfileDto copyWith({
    String? id,
    String? name,
    String? lastSeenAt,
    bool? isOnline,
    bool? isFavorited,
    String? profileImage,
    String? profileId,
    String? referralCode,
    String? email,
    String? status,
    List<Category>? categories,
    List<PortfolioItem>? portfolio,
    List<Availability>? availability,
    bool? isPremium,
    String? location,
    String? workMode,
    bool? availableToTravel,
    RatingsAndReviews? ratingsAndReviews,
    Analytics? analytics,
    String? countryCode,
    String? primaryCurrency,
    ExchangeRateInfo? exchangeRateInfo,
  }) =>
      CreatorProfileDto(
        id: id ?? this.id,
        name: name ?? this.name,
        lastSeenAt: lastSeenAt ?? this.lastSeenAt,
        isOnline: isOnline ?? this.isOnline,
        isFavorited: isFavorited ?? this.isFavorited,
        profileImage: profileImage ?? this.profileImage,
        profileId: profileId ?? this.profileId,
        referralCode: referralCode ?? this.referralCode,
        countryCode: countryCode ?? this.countryCode,
        primaryCurrency: primaryCurrency ?? this.primaryCurrency,
        email: email ?? this.email,
        status: status ?? this.status,
        categories: categories ?? this.categories,
        isPremium: isPremium ?? this.isPremium,
        portfolio: portfolio ?? this.portfolio,
        location: location ?? this.location,
        workMode: workMode ?? this.workMode,
        availableToTravel: availableToTravel ?? this.availableToTravel,
        ratingsAndReviews: ratingsAndReviews ?? this.ratingsAndReviews,
        analytics: analytics ?? this.analytics,
        exchangeRateInfo: exchangeRateInfo ?? this.exchangeRateInfo,
        //availability: availability ?? this.availability,
      );

  factory CreatorProfileDto.fromJson(Map<String, dynamic> json) => CreatorProfileDto(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        status: json["status"],
        lastSeenAt: json["last_seen_at"],
        isOnline: json["is_online"],
        isFavorited: json["is_favorited"],
        profileImage: json["profile_image"],
        profileId: json["profile_id"],
        referralCode: json["referral_code"],
        isPremium: json["is_premium"],
        countryCode: json["country_code"],
        primaryCurrency: json["primary_currency"],
        categories: json["categories"] == null
            ? []
            : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
        portfolio: json["portfolio"] == null
            ? []
            : List<PortfolioItem>.from(json["portfolio"]!.map((x) => PortfolioItem.fromJson(x))),
        location: json["location"],
        workMode: json["work_mode"],
        availableToTravel: json["available_to_travel"],
        ratingsAndReviews: json["ratings_and_reviews"] == null
            ? null
            : RatingsAndReviews.fromJson(json["ratings_and_reviews"]),
        // availability: json["availability"] == null
        //     ? []
        //     : List<Availability>.from(json["availability"]!.map((x) => Availability.fromJson(x))),
        analytics: json["analytics"] == null ? null : Analytics.fromJson(json["analytics"]),
        exchangeRateInfo: json["exchange_rate_info"] == null
            ? null
            : ExchangeRateInfo.fromJson(json["exchange_rate_info"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "last_seen_at": lastSeenAt,
        "is_online": isOnline,
        "is_favorited": isFavorited,
        "is_premium": isPremium,
        "country_code": countryCode,
        "primary_currency": primaryCurrency,
        "status": status,
        "profile_image": profileImage,
        "profile_id": profileId,
        "referral_code": referralCode,
        "categories":
            categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
        "portfolio": portfolio == null ? [] : List<dynamic>.from(portfolio!.map((x) => x.toJson())),
        "location": location,
        "work_mode": workMode,
        "available_to_travel": availableToTravel,
        "ratings_and_reviews": ratingsAndReviews?.toJson(),
        "analytics": analytics?.toJson(),
        "exchange_rate_info": exchangeRateInfo?.toJson(),
        // "availability":
        //     availability == null ? [] : List<dynamic>.from(availability!.map((x) => x.toJson())),
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
  final String? currency;
  final String? pricingType;
  final ConvertedPrice? convertedPrice;

  Service({
    this.serviceId,
    this.serviceName,
    this.price,
    this.currency,
    this.pricingType,
    this.convertedPrice,
  });

  Service copyWith({
    String? serviceId,
    String? serviceName,
    num? price,
    String? currency,
    String? pricingType,
    ConvertedPrice? convertedPrice,
  }) =>
      Service(
        serviceId: serviceId ?? this.serviceId,
        serviceName: serviceName ?? this.serviceName,
        price: price ?? this.price,
        currency: currency ?? this.currency,
        pricingType: pricingType ?? this.pricingType,
        convertedPrice: convertedPrice ?? this.convertedPrice,
      );

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        serviceId: json["service_id"],
        serviceName: json["service_name"],
        price: json["price"],
        currency: json["currency"],
        pricingType: json["pricing_type"],
        convertedPrice: json["converted_price"] == null
            ? null
            : ConvertedPrice.fromJson(json["converted_price"]),
      );

  Map<String, dynamic> toJson() => {
        "service_id": serviceId,
        "service_name": serviceName,
        "price": price,
        "currency": currency,
        "pricing_type": pricingType,
        "converted_price": convertedPrice?.toJson(),
      };
}

class ConvertedPrice {
  final num? amount;
  final String? currency;
  final String? display;

  ConvertedPrice({
    this.amount,
    this.currency,
    this.display,
  });

  factory ConvertedPrice.fromJson(Map<String, dynamic> json) => ConvertedPrice(
        amount: json["amount"],
        currency: json["currency"],
        display: json["display"],
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "currency": currency,
        "display": display,
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
  final num? cancellationRate;
  final num? completionRate;
  final num? repeatHireRate;
  final num? averageResponseTime;
  final DateTime? memberSince;

  Analytics({
    this.totalBookings,
    this.cancellationRate,
    this.completionRate,
    this.repeatHireRate,
    this.averageResponseTime,
    this.memberSince,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) => Analytics(
        totalBookings: json["total_bookings"],
        cancellationRate: json["cancellation_rate"],
        completionRate: json["completion_rate"]?.toDouble(),
        repeatHireRate: json["repeat_hire_rate"],
        averageResponseTime: json["average_response_time"]?.toDouble(),
        memberSince: json["member_since"] == null ? null : DateTime.parse(json["member_since"]),
      );

  Map<String, dynamic> toJson() => {
        "total_bookings": totalBookings,
        "cancellation_rate": cancellationRate,
        "completion_rate": completionRate,
        "repeat_hire_rate": repeatHireRate,
        "average_response_time": averageResponseTime,
        "member_since":
            "${memberSince!.year.toString().padLeft(4, '0')}-${memberSince!.month.toString().padLeft(2, '0')}-${memberSince!.day.toString().padLeft(2, '0')}",
      };
}

class ExchangeRateInfo {
  final num? rate;
  final String? from;
  final String? to;
  final num? marginPercentage;
  final String? display;

  ExchangeRateInfo({
    this.rate,
    this.from,
    this.to,
    this.marginPercentage,
    this.display,
  });

  factory ExchangeRateInfo.fromJson(Map<String, dynamic> json) => ExchangeRateInfo(
        rate: json["rate"],
        from: json["from"],
        to: json["to"],
        marginPercentage: json["margin_percentage"],
        display: json["display"],
      );

  Map<String, dynamic> toJson() => {
        "rate": rate,
        "from": from,
        "to": to,
        "margin_percentage": marginPercentage,
        "display": display,
      };
}
