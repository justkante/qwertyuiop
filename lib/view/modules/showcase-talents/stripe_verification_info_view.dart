import 'package:creatify_mobile/data/models/responses/onboard_stripe_dto.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/stripe_creator_onboard_vm.dart';
import 'package:creatify_mobile/view/modules/webview/app_webview.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StripeVerificationInfoView extends ConsumerWidget {
  const StripeVerificationInfoView({super.key});

  static const _reasons = [
    'We verify creator identities',
    'We prevent fraud',
    'We ensure you get paid directly to your account',
    'We protect both creators and recruiters',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stripeOnboardingStatus = ref.watch(stripeCreatorOnboardProvider);

    // Stripe Onboarding
    ref.listen(stripeCreatorOnboardProvider, (_, value) {
      if (value is AsyncData<StripeOnboardDto>) {
        context.pushReplacement(
          WebviewScreen(
            url: value.value.onboardingUrl ?? '',
            routeName: 'Creator Onboarding',
          ),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Verify your Account',
                  style: context.textTheme.headlineSmall?.copyWith(fontSize: 23),
                ),
                6.0.width,
                SvgPicture.asset(
                  AppImages.secure,
                  width: 24,
                  height: 24,
                ),
              ],
            ),
            12.0.height,
            Text(
              'Why you need to complete Stripe Verification',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            8.0.height,
            Text(
              'To receive payments securely:',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.subHeading,
              ),
            ),
            24.0.height,
            for (final reason in _reasons)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      AppImages.checkMark,
                      width: 20,
                      height: 20,
                      colorFilter: AppColors.primary.colorFilterMode(),
                    ),
                    12.0.width,
                    Expanded(
                      child: Text(
                        reason,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.subHeading,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          12.0.height,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: MainButton(
              text: 'Continue to Verification',
              isLoading: stripeOnboardingStatus.isLoading,
              onPressed: () {
                ref.read(stripeCreatorOnboardProvider.notifier).stripeCreatorOnboard();
              },
            ),
          ),
          24.0.height,
        ],
      ),
    );
  }
}
