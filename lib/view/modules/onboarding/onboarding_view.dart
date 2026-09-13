import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/view/modules/authentication/login_view.dart';
import 'package:creatify_mobile/view/modules/authentication/signup_view.dart';
import 'package:creatify_mobile/view/modules/onboarding/widgets/onboarding_list.dart';
import 'package:creatify_mobile/view/modules/search-talents/search_talents_view.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75.h,
        title: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Image.asset(
            AppImages.logo,
            width: 50,
            height: 50,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: onboardingScreenList.length,
                itemBuilder: (context, index) {
                  final item = onboardingScreenList[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 325.h,
                        width: 325.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.asset(item.image),
                      ),
                      12.0.height,
                      Text(
                        item.title,
                        style: context.textTheme.displayLarge,
                        textAlign: TextAlign.center,
                      ),
                      6.0.height,
                      Text(
                        item.subtitle,
                        style: context.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      2.0.height,
                    ],
                  );
                },
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: SmoothPageIndicator(
                  controller: pageController,
                  count: 3,
                  effect: SlideEffect(
                    dotWidth: 10.w,
                    dotHeight: 10.h,
                    activeDotColor: AppColors.highlightCoral,
                    dotColor: AppColors.grey300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MainButton(
              text: 'Create an account',
              onPressed: () {
                SharedPrefManager.isFirstLaunch = false;
                context.pushAndRemoveUntil(const SignupView());
              },
            ),
            8.0.height,
            MainButton(
              text: 'Log In',
              color: AppColors.btnTertiary,
              textColor: AppColors.btnText,
              onPressed: () {
                SharedPrefManager.isFirstLaunch = false;
                context.pushAndRemoveUntil(const LoginView());
              },
            ),
            20.0.height,
            InkWell(
              onTap: () {
                SharedPrefManager.isFirstLaunch = false;
                context.push(const SearchTalentsView());
              },
              child: Text(
                'Continue as Guest',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            12.0.height,
          ],
        ),
      ),
    );
  }
}
