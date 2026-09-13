// To parse this JSON data, do
//
//     final stripeOnboardDto = stripeOnboardDtoFromJson(jsonString);

import 'dart:convert';

StripeOnboardDto stripeOnboardDtoFromJson(String str) =>
    StripeOnboardDto.fromJson(json.decode(str));

String stripeOnboardDtoToJson(StripeOnboardDto data) => json.encode(data.toJson());

class StripeOnboardDto {
  final String? onboardingUrl;
  final DateTime? expiresAt;
  final String? stripeAccountId;

  StripeOnboardDto({
    this.onboardingUrl,
    this.expiresAt,
    this.stripeAccountId,
  });

  factory StripeOnboardDto.fromJson(Map<String, dynamic> json) => StripeOnboardDto(
        onboardingUrl: json["onboarding_url"],
        expiresAt: json["expires_at"] == null ? null : DateTime.parse(json["expires_at"]),
        stripeAccountId: json["stripe_account_id"],
      );

  Map<String, dynamic> toJson() => {
        "onboarding_url": onboardingUrl,
        "expires_at": expiresAt?.toIso8601String(),
        "stripe_account_id": stripeAccountId,
      };
}
