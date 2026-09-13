import 'dart:developer';

import 'package:creatify_mobile/core/env/env.dart';
import 'package:creatify_mobile/main.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/my_creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/payout_details_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/portfolio_upload_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/rates_card_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/set_availability_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/stripe_verification_info_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/stripe_creator_onboard_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/linear_loading.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dojah_kyc/flutter_dojah_kyc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingSheet extends ConsumerStatefulWidget {
  const OnboardingSheet({super.key});

  @override
  ConsumerState<OnboardingSheet> createState() => _OnboardingSheetState();
}

class _OnboardingSheetState extends ConsumerState<OnboardingSheet> {
  late Map<String, dynamic> dojahKycUserData;
  late Map<String, dynamic> dojahKycMetaData;
  late Map<String, dynamic> dojahConfigObj;

  void userDetails() async {
    var user = ref.read(userControllerProvider);
    dojahKycUserData = {
      "first_name": user.name?.split(' ').first,
      "last_name": user.name?.split(' ').last,
      "residence_country": "Nigeria",
      "email": user.email,
    };

    // Dojah KYC Meta Data
    dojahKycMetaData = {
      "user_id": user.id,
      "email": user.email,
      "level": "1",
    };

    dojahConfigObj = {
      "widget_id": environmentNotifier.value == 'dev' ? Env.dojohWidgetId : Env.prodDojahWidgetId,
    };
  }

  openDojah() async {
    log('Widget ID: ${dojahConfigObj['widget_id']}, ENV: ${environmentNotifier.value}');
    //Initialize the Dojah Widget
    final DojahKYC dojahKYC = DojahKYC(
      appId: "",
      title: 'KYC Verification',
      publicKey: "",
      type: "custom",
      metaData: dojahKycMetaData,
      config: dojahConfigObj,
      userData: dojahKycUserData,
    );

    // Persmission Handler
    log('Camera Permission Status: ${await Permission.camera.status.isGranted}');
    final status = await Permission.camera.request();

    // Open the KYC WebView
    if (status.isGranted) {
      if (!mounted) return;
      dojahKYC.open(
        context,
        onSuccess: (result) {
          log(result.toString());

          if (result[0]['message'] == 'Session completed') {
            if (context.mounted) {
              log('In Dojah context');
              ref.invalidate(getOnboardingStatusProvider);
            }
          }

          if (kDebugMode) {
            log("Success");
          }
        },
        onClose: (close) {
          NavigationService.instance.currentState?.context.pop();
          if (kDebugMode) {
            log('Widget Closed');
          }
        },
        onError: (err) {
          if (kDebugMode) {
            log('error: $err');
          }
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    userDetails();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingStatus = ref.watch(getOnboardingStatusProvider);
    final stripeOnboardingStatus = ref.watch(stripeCreatorOnboardProvider);
    final userData = ref.watch(userControllerProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppImages.logo,
          height: 56,
          width: 56,
        ),
        14.0.height,
        Text(
          'Set up Creator Profile',
          style: context.textTheme.headlineSmall?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        8.0.height,
        Text(
          "Just get started — you can update your rates, portfolio, and availability anytime after setup.",
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall,
        ),
        32.0.height,
        if (stripeOnboardingStatus.isLoading || onboardingStatus.isLoading) ...[
          const LineLoadingIndicator(loading: true),
          12.0.height,
        ],
        onboardingStatus.when(
          data: (data) {
            return Column(
              children: [
                for (var kycItem in [
                  if (userData.countryCode == 'NG') ...[
                    (
                      AppImages.kyc,
                      'KYC Requirements',
                      data.steps?.kyc ?? 'not_started',
                      () {
                        openDojah();
                      },
                    ),
                    (
                      AppImages.bank,
                      'Payout Details',
                      data.steps?.payout ?? 'not_started',
                      () {
                        context.push(const PayoutDetailsView());
                      }
                    ),
                  ] else ...[
                    (
                      AppImages.kyc,
                      'KYC and Payout Setup',
                      data.steps?.kyc ?? 'not_started',
                      () {
                        context.push(const StripeVerificationInfoView());
                      },
                    ),
                  ],
                  (
                    AppImages.clipboard,
                    'Rates Card',
                    data.steps?.categories ?? 'not_started',
                    () {
                      context.push(const RatesCardView());
                    }
                  ),
                  (
                    AppImages.suitcase,
                    'Portfolio',
                    data.steps?.portfolio ?? 'not_started',
                    () {
                      context.push(const PortfolioUploadView());
                    }
                  ),
                  (
                    AppImages.calendarLine,
                    'Availability',
                    data.steps?.availability ?? 'not_started',
                    () {
                      context.push(const SetAvailabilityView());
                    }
                  ),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: KycItem(
                      image: kycItem.$1,
                      title: kycItem.$2,
                      status: kycItem.$3,
                      onTap: kycItem.$4,
                    ),
                  ),
                if ((data.isOnboarded == true || data.completedAt != null)) ...[
                  32.0.height,
                  MainButton(
                    text: 'Continue to Profile',
                    onPressed: () {
                      context.pop();
                      context.push(const MyCreatorProfileView());
                    },
                  ),
                ],
              ],
            );
          },
          loading: () => const CircularProgressIndicator.adaptive(),
          error: (error, stackTrace) {
            return Center(
              child: Text(
                'Error: $error',
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
        12.0.height,
      ],
    );
  }
}

class KycItem extends StatelessWidget {
  final String image, title, status;
  final Function()? onTap;
  final bool isLoading;
  const KycItem({
    super.key,
    required this.image,
    required this.title,
    required this.status,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: switch (status) {
        'not_started' || 'in_progress' || 'abandoned' || 'failed' => onTap,
        'completed' when title.contains('Portfolio') => onTap,
        'pending' || 'completed' || _ => null,
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              image,
              height: 20,
              width: 20,
              colorFilter: AppColors.icons.colorFilterMode(),
            ),
            8.0.width,
            Text(
              title,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.subHeading,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: switch (status) {
                  'completed' => AppColors.primary,
                  'failed' => AppColors.kErrorColor,
                  'in_progress' || 'abandoned' => AppColors.yellow600,
                  'pending' => AppColors.yellow600,
                  'not_started' => AppColors.btnInactive,
                  _ => AppColors.btnInactive,
                },
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                switch (status) {
                  'completed' => 'Done',
                  'failed' => 'Failed',
                  'in_progress' || 'abandoned' => 'In Progress',
                  'pending' => 'Pending',
                  'not_started' || _ => 'Not Started',
                },
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            isLoading
                ? const CircularProgressIndicator.adaptive()
                : switch (status) {
                    'not_started' || 'in_progress' || 'abandoned' || 'failed' => Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: SvgPicture.asset(
                          AppImages.chevronRight,
                          height: 18,
                          width: 18,
                          colorFilter: AppColors.black2.colorFilterMode(),
                        ),
                      ),
                    'completed' when title.contains('Portfolio') => Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: SvgPicture.asset(
                          AppImages.chevronRight,
                          height: 18,
                          width: 18,
                          colorFilter: AppColors.black2.colorFilterMode(),
                        ),
                      ),
                    'completed' || 'pending' || _ => const SizedBox.shrink(),
                  },
          ],
        ),
      ),
    );
  }
}
