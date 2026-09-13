// To parse this JSON data, do
//
//     final ambassadorReferredUsers = ambassadorReferredUsersFromJson(jsonString);

import 'dart:convert';

AmbassadorStats ambassadorReferredUsersFromJson(String str) =>
    AmbassadorStats.fromJson(json.decode(str));

String ambassadorReferredUsersToJson(AmbassadorStats data) => json.encode(data.toJson());

class AmbassadorStats {
  final bool? success;
  final Stats? stats;
  final List<Datum>? data;

  AmbassadorStats({
    this.success,
    this.stats,
    this.data,
  });

  factory AmbassadorStats.fromJson(Map<String, dynamic> json) => AmbassadorStats(
        success: json["success"],
        stats: json["stats"] == null ? null : Stats.fromJson(json["stats"]),
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "stats": stats?.toJson(),
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  final String? id;
  final ReferredUser? referredUser;
  final String? referredUserRole;
  final num? bookingAmount;
  final num? commissionAmount;
  final String? currency;
  final String? status;
  final DateTime? creditedAt;
  final DateTime? createdAt;

  Datum({
    this.id,
    this.referredUser,
    this.referredUserRole,
    this.bookingAmount,
    this.commissionAmount,
    this.currency,
    this.status,
    this.creditedAt,
    this.createdAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        referredUser:
            json["referred_user"] == null ? null : ReferredUser.fromJson(json["referred_user"]),
        referredUserRole: json["referred_user_role"],
        bookingAmount: json["booking_amount"],
        commissionAmount: json["commission_amount"],
        currency: json["currency"],
        status: json["status"],
        creditedAt: json["credited_at"] == null ? null : DateTime.parse(json["credited_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "referred_user": referredUser?.toJson(),
        "referred_user_role": referredUserRole,
        "booking_amount": bookingAmount,
        "commission_amount": commissionAmount,
        "currency": currency,
        "status": status,
        "credited_at": creditedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
      };
}

class ReferredUser {
  final String? id;
  final String? name;
  final String? profileImage;

  ReferredUser({
    this.id,
    this.name,
    this.profileImage,
  });

  factory ReferredUser.fromJson(Map<String, dynamic> json) => ReferredUser(
        id: json["id"],
        name: json["name"],
        profileImage: json["profile_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "profile_image": profileImage,
      };
}

class Stats {
  final bool? isAmbassador;
  final String? referralCode;
  final int? totalReferrals;
  final int? completedReferrals;
  final int? pendingReferrals;
  final num? totalCommissionEarned;
  final num? unclaimedCommission;
  final num? commissionPercentage;

  Stats({
    this.isAmbassador,
    this.referralCode,
    this.totalReferrals,
    this.completedReferrals,
    this.pendingReferrals,
    this.totalCommissionEarned,
    this.unclaimedCommission,
    this.commissionPercentage,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
        isAmbassador: json["is_ambassador"],
        referralCode: json["referral_code"],
        totalReferrals: json["total_referrals"],
        completedReferrals: json["completed_referrals"],
        pendingReferrals: json["pending_referrals"],
        totalCommissionEarned: json["total_commission_earned"],
        unclaimedCommission: json["unclaimed_commission"],
        commissionPercentage: json["commission_percentage"],
      );

  Map<String, dynamic> toJson() => {
        "is_ambassador": isAmbassador,
        "referral_code": referralCode,
        "total_referrals": totalReferrals,
        "completed_referrals": completedReferrals,
        "pending_referrals": pendingReferrals,
        "total_commission_earned": totalCommissionEarned,
        "unclaimed_commission": unclaimedCommission,
        "commission_percentage": commissionPercentage,
      };
}
