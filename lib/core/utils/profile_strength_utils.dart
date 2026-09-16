import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/data/models/responses/onboarding_status_dto.dart';
import 'package:creatify_mobile/data/models/responses/user_dto.dart';

class ProfileStrengthUtils {
  static double calculateStrength({
    required UserDto user,
    required OnboardingStatusDto? onboardingStatus,
    required CreatorProfileDto? creatorProfile,
  }) {
    double strength = 0.0;

    // 1. Basic profile completed (photo, bio, location, niche) — 20%
    bool hasPhoto = user.profileImage != null && user.profileImage!.isNotEmpty;
    bool hasLocation = user.countryCode != null && user.countryCode!.isNotEmpty;
    bool hasNiche = creatorProfile?.categories != null && creatorProfile!.categories!.isNotEmpty;

    int basicComponents = 0;
    if (hasPhoto) basicComponents++;
    if (hasLocation) basicComponents++;
    if (hasNiche) basicComponents++;

    strength += (basicComponents / 3) * 20;

    if (onboardingStatus != null && onboardingStatus.steps != null) {
      final steps = onboardingStatus.steps!;

      // 2. KYC + payout setup completed — 25%
      if (steps.kyc == 'completed') strength += 12.5;
      if (steps.payout == 'completed') strength += 12.5;

      // 3. Portfolio uploaded — 25%
      if (steps.portfolio == 'completed') {
        strength += 25;
      }

      // 4. Rates card completed — 10%
      if (steps.categories == 'completed') {
        strength += 10;
      }

      // 5. Availability completed — 10%
      if (steps.availability == 'completed') {
        strength += 10;
      }
    }

    // 6. Skills/services added — 10%
    bool hasServices = creatorProfile?.categories?.any((c) => c.services != null && c.services!.isNotEmpty) ?? false;
    if (hasServices) {
      strength += 10;
    }

    return strength.clamp(0, 100);
  }

  static double calculateStrengthForProfile(CreatorProfileDto profile) {
    double strength = 0.0;

    // Basic profile (Approximate for profile only)
    if (profile.profileImage != null) strength += 6.6;
    if (profile.countryCode != null) strength += 6.6;
    if (profile.categories?.isNotEmpty == true) strength += 6.8;

    // Others (Approximate based on profile fields)
    if (profile.status == 'active') strength += 25; // KYC/Payout proxy
    if (profile.portfolio?.isNotEmpty == true) strength += 25;
    if (profile.categories?.any((c) => c.services?.isNotEmpty == true) == true) {
      strength += 20; // Rates + Skills proxy
    }

    // Availability
    // if (profile.availability?.isNotEmpty == true) strength += 10;

    return strength.clamp(0, 100);
  }

  static String getStrengthLabel(double strength) {
    if (strength <= 39) return 'Getting Started';
    if (strength <= 69) return 'Building Your Profile';
    if (strength <= 89) return 'Strong Profile';
    return 'Ready to Be Discovered';
  }
}
