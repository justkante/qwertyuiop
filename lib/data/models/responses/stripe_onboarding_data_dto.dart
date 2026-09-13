// To parse this JSON data, do
//
//     final stripeOnboardingData = stripeOnboardingDataFromJson(jsonString);

import 'dart:convert';

StripeOnboardingData stripeOnboardingDataFromJson(String str) =>
    StripeOnboardingData.fromJson(json.decode(str));

String stripeOnboardingDataToJson(StripeOnboardingData data) => json.encode(data.toJson());

class StripeOnboardingData {
  final bool? requiresStripeOnboarding;
  final String? onboardingUrl;
  final DateTime? expiresAt;
  final String? stripeAccountId;

  StripeOnboardingData({
    this.requiresStripeOnboarding,
    this.onboardingUrl,
    this.expiresAt,
    this.stripeAccountId,
  });

  factory StripeOnboardingData.fromJson(Map<String, dynamic> json) => StripeOnboardingData(
        requiresStripeOnboarding: json["requires_stripe_onboarding"],
        onboardingUrl: json["onboarding_url"],
        expiresAt: json["expires_at"] == null ? null : DateTime.parse(json["expires_at"]),
        stripeAccountId: json["stripe_account_id"],
      );

  Map<String, dynamic> toJson() => {
        "requires_stripe_onboarding": requiresStripeOnboarding,
        "onboarding_url": onboardingUrl,
        "expires_at": expiresAt?.toIso8601String(),
        "stripe_account_id": stripeAccountId,
      };
}
