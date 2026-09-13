import 'dart:convert';

OnboardingStatusDto onboardingStatusDtoFromJson(String str) =>
    OnboardingStatusDto.fromJson(json.decode(str));

String onboardingStatusDtoToJson(OnboardingStatusDto data) => json.encode(data.toJson());

class OnboardingStatusDto {
  final bool? isOnboarded;
  final int? currentStep;
  final int? nextStep;
  final int? completionPercentage;
  final dynamic completedAt;
  final Steps? steps;

  OnboardingStatusDto({
    this.isOnboarded,
    this.currentStep,
    this.nextStep,
    this.completionPercentage,
    this.completedAt,
    this.steps,
  });

  factory OnboardingStatusDto.fromJson(Map<String, dynamic> json) => OnboardingStatusDto(
        isOnboarded: json["is_onboarded"],
        currentStep: json["current_step"],
        nextStep: json["next_step"],
        completionPercentage: json["completion_percentage"],
        completedAt: json["completed_at"],
        steps: json["steps"] == null ? null : Steps.fromJson(json["steps"]),
      );

  Map<String, dynamic> toJson() => {
        "is_onboarded": isOnboarded,
        "current_step": currentStep,
        "next_step": nextStep,
        "completion_percentage": completionPercentage,
        "completed_at": completedAt,
        "steps": steps?.toJson(),
      };
}

class Steps {
  final String? kyc;
  final String? payout;
  final String? categories;
  final String? portfolio;
  final String? availability;

  Steps({
    this.kyc,
    this.payout,
    this.categories,
    this.portfolio,
    this.availability,
  });

  factory Steps.fromJson(Map<String, dynamic> json) => Steps(
        kyc: json["kyc"],
        payout: json["payout"],
        categories: json["categories"],
        portfolio: json["portfolio"],
        availability: json["availability"],
      );

  Map<String, dynamic> toJson() => {
        "kyc": kyc,
        "payout": payout,
        "categories": categories,
        "portfolio": portfolio,
        "availability": availability,
      };
}
