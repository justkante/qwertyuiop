// To parse this JSON data, do
//
//     final referralStats = referralStatsFromJson(jsonString);

import 'dart:convert';

ReferralStats referralStatsFromJson(String str) => ReferralStats.fromJson(json.decode(str));

String referralStatsToJson(ReferralStats data) => json.encode(data.toJson());

class ReferralStats {
  final String? referralCode;
  final int? totalReferrals;
  final int? completedReferrals;
  final int? pendingReferrals;
  final int? maxReferrals;
  final num? referralBalance;
  final num? totalEarned;
  final num? totalClaimed;
  final bool? canClaim;
  final bool? campaignActive;

  ReferralStats({
    this.referralCode,
    this.totalReferrals,
    this.completedReferrals,
    this.pendingReferrals,
    this.maxReferrals,
    this.referralBalance,
    this.totalEarned,
    this.totalClaimed,
    this.canClaim,
    this.campaignActive,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) => ReferralStats(
        referralCode: json["referral_code"],
        totalReferrals: json["total_referrals"],
        completedReferrals: json["completed_referrals"],
        pendingReferrals: json["pending_referrals"],
        maxReferrals: json["max_referrals"],
        referralBalance: json["referral_balance"],
        totalEarned: json["total_earned"],
        totalClaimed: json["total_claimed"],
        canClaim: json["can_claim"],
        campaignActive: json["campaign_active"],
      );

  Map<String, dynamic> toJson() => {
        "referral_code": referralCode,
        "total_referrals": totalReferrals,
        "completed_referrals": completedReferrals,
        "pending_referrals": pendingReferrals,
        "max_referrals": maxReferrals,
        "referral_balance": referralBalance,
        "total_earned": totalEarned,
        "total_claimed": totalClaimed,
        "can_claim": canClaim,
        "campaign_active": campaignActive,
      };
}
