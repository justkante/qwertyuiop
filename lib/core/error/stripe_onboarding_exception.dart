import 'package:creatify_mobile/data/models/responses/stripe_onboarding_data_dto.dart';

class StripeOnboardingException implements Exception {
  final String message;
  final StripeOnboardingData onboardingData;

  StripeOnboardingException({
    required this.message,
    required this.onboardingData,
  });

  @override
  String toString() => message;
}
