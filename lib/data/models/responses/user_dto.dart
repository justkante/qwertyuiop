import 'dart:convert';
import 'review_dto.dart';

UserDto userDtoFromJson(String str) => UserDto.fromJson(json.decode(str));

String userDtoToJson(UserDto data) => json.encode(data.toJson());

class UserDto {
  final String? id;
  final String? name;
  final String? email;
  final String? countryCode;
  final String? primaryCurrency;
  final String? stripeCustomerId;
  final String? timezone;
  final DateTime? countryUpdatedAt;
  final String? profileId;
  final String? referralCode;
  final bool? hasUsedReferralCode;
  final String? authStrategy;
  final DateTime? emailVerifiedAt;
  final DateTime? deletedAt;
  final String? profileImage;
  final bool? isPremium;
  final DateTime? premiumSince;
  final bool? isOnline;
  final DateTime? lastSeenAt;
  final DateTime? lastLoginAt;
  final DateTime? passwordChangedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? providerId;
  final String? referredByCode;
  final String? countryFlag;
  final List<String>? roles;
  final List<ReviewDto>? reviewsReceived;

  UserDto({
    this.id,
    this.name,
    this.email,
    this.countryCode,
    this.primaryCurrency,
    this.stripeCustomerId,
    this.timezone,
    this.countryUpdatedAt,
    this.profileId,
    this.referralCode,
    this.hasUsedReferralCode,
    this.authStrategy,
    this.emailVerifiedAt,
    this.deletedAt,
    this.profileImage,
    this.isPremium,
    this.premiumSince,
    this.isOnline,
    this.lastSeenAt,
    this.lastLoginAt,
    this.passwordChangedAt,
    this.createdAt,
    this.updatedAt,
    this.providerId,
    this.referredByCode,
    this.countryFlag,
    this.roles,
    this.reviewsReceived,
  });

  String get getInitials =>
      '${name?.split(' ').first.substring(0, 1).toUpperCase()}${name?.split(' ').last.substring(0, 1).toUpperCase()}';

  UserDto copyWith({
    String? id,
    String? name,
    String? email,
    String? countryCode,
    String? primaryCurrency,
    String? stripeCustomerId,
    String? timezone,
    DateTime? countryUpdatedAt,
    String? profileId,
    String? referralCode,
    bool? hasUsedReferralCode,
    String? authStrategy,
    DateTime? emailVerifiedAt,
    DateTime? deletedAt,
    String? profileImage,
    bool? isPremium,
    DateTime? premiumSince,
    bool? isOnline,
    DateTime? lastSeenAt,
    DateTime? lastLoginAt,
    DateTime? passwordChangedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? providerId,
    String? referredByCode,
    String? countryFlag,
    List<String>? roles,
    List<ReviewDto>? reviewsReceived,
  }) =>
      UserDto(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        countryCode: countryCode ?? this.countryCode,
        primaryCurrency: primaryCurrency ?? this.primaryCurrency,
        stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
        timezone: timezone ?? this.timezone,
        countryUpdatedAt: countryUpdatedAt ?? this.countryUpdatedAt,
        profileId: profileId ?? this.profileId,
        referralCode: referralCode ?? this.referralCode,
        hasUsedReferralCode: hasUsedReferralCode ?? this.hasUsedReferralCode,
        authStrategy: authStrategy ?? this.authStrategy,
        emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        profileImage: profileImage ?? this.profileImage,
        isPremium: isPremium ?? this.isPremium,
        premiumSince: premiumSince ?? this.premiumSince,
        isOnline: isOnline ?? this.isOnline,
        lastSeenAt: lastSeenAt ?? this.lastSeenAt,
        lastLoginAt: lastLoginAt ?? this.lastLoginAt,
        passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        providerId: providerId ?? this.providerId,
        referredByCode: referredByCode ?? this.referredByCode,
        countryFlag: countryFlag ?? this.countryFlag,
        roles: roles ?? this.roles,
        reviewsReceived: reviewsReceived ?? this.reviewsReceived,
      );

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        countryCode: json["country_code"],
        primaryCurrency: json["primary_currency"],
        stripeCustomerId: json["stripe_customer_id"],
        timezone: json["timezone"],
        countryUpdatedAt:
            json["country_updated_at"] == null ? null : DateTime.tryParse(json["country_updated_at"].toString()),
        profileId: json["profile_id"],
        referralCode: json["referral_code"],
        hasUsedReferralCode: json["has_used_referral_code"],
        authStrategy: json["auth_strategy"],
        emailVerifiedAt:
            json["email_verified_at"] == null ? null : DateTime.tryParse(json["email_verified_at"].toString()),
        deletedAt: json["deleted_at"] == null ? null : DateTime.tryParse(json["deleted_at"].toString()),
        profileImage: json["profile_image"],
        isPremium: json["is_premium"],
        premiumSince: json["premium_since"] == null ? null : DateTime.tryParse(json["premium_since"].toString()),
        isOnline: json["is_online"],
        lastSeenAt: json["last_seen_at"] == null ? null : DateTime.tryParse(json["last_seen_at"].toString()),
        lastLoginAt: json["last_login_at"] == null ? null : DateTime.tryParse(json["last_login_at"].toString()),
        passwordChangedAt: json["password_changed_at"] == null
            ? null
            : DateTime.tryParse(json["password_changed_at"].toString()),
        createdAt: json["created_at"] == null ? null : DateTime.tryParse(json["created_at"].toString()),
        updatedAt: json["updated_at"] == null ? null : DateTime.tryParse(json["updated_at"].toString()),
        providerId: json["provider_id"],
        referredByCode: json["referred_by_code"],
        countryFlag: json["country_flag"],
        roles: json["roles"] == null ? null : List<String>.from(json["roles"].map((x) => x)),
        reviewsReceived: json["reviews_received"] == null
            ? null
            : List<ReviewDto>.from(json["reviews_received"].map((x) => ReviewDto.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "country_code": countryCode,
        "primary_currency": primaryCurrency,
        "stripe_customer_id": stripeCustomerId,
        "timezone": timezone,
        "country_updated_at": countryUpdatedAt?.toIso8601String(),
        "profile_id": profileId,
        "referral_code": referralCode,
        "has_used_referral_code": hasUsedReferralCode,
        "auth_strategy": authStrategy,
        "email_verified_at": emailVerifiedAt?.toIso8601String(),
        "deleted_at": deletedAt?.toIso8601String(),
        "profile_image": profileImage,
        "is_premium": isPremium,
        "premium_since": premiumSince?.toIso8601String(),
        "is_online": isOnline,
        "last_seen_at": lastSeenAt?.toIso8601String(),
        "last_login_at": lastLoginAt?.toIso8601String(),
        "password_changed_at": passwordChangedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "provider_id": providerId,
        "referred_by_code": referredByCode,
        "country_flag": countryFlag,
        "roles": roles == null ? null : List<dynamic>.from(roles!.map((x) => x)),
        "reviews_received": reviewsReceived == null ? null : List<dynamic>.from(reviewsReceived!.map((x) => x)), // Assuming ReviewDto has toJson if needed, but for now we only need fromJson
      };
}
