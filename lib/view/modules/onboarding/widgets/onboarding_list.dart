import 'package:creatify_mobile/view/utils/app_images.dart';

class OnboardingList {
  final String title;
  final String subtitle;
  final String image;

  OnboardingList({
    required this.title,
    required this.subtitle,
    required this.image,
  });
}

List<OnboardingList> onboardingScreenList = [
  OnboardingList(
    title: 'Hire top creative talent',
    subtitle:
        'Browse a diverse community of creatives and book the right talent for your next project, event, or campaign',
    image: AppImages.onboarding1,
  ),
  OnboardingList(
    title: 'Showcase your talent',
    subtitle:
        'Put your talent in the spotlight - build your profile, set your terms, and attract new opportunities',
    image: AppImages.onboarding2,
  ),
  OnboardingList(
    title: 'One profile, endless possibilities',
    subtitle: 'Hire talent or offer your own, all from the same account',
    image: AppImages.onboarding3,
  ),
];
