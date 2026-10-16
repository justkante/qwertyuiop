import 'dart:developer';

import 'package:creatify_mobile/core/env/env.dart';
import 'package:creatify_mobile/main.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/payout_details_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/portfolio_upload_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/rates_card_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/set_availability_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/start_onboarding_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
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
      "widget_id": environmentNotifier.value == "prod" ? Env.prodDojahWidgetId : Env.dojohWidgetId,
    };
  }

  openDojah() async {
    log('Widget ID: ${dojahConfigObj['widget_id']}, ENV: ${environmentNotifier.value}');
    //Initialize the Dojah Widget
    final DojahKYC dojahKYC = DojahKYC(
      appId: "692d312324af1f656a3baba4",
      title: 'KYC Verification',
      publicKey: "prod_pk_ktitGxzcNu6RVYogNBEr18foV",
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
          log('Dojah error: $err');
          if (context.mounted) {
            ToastDialog.showError('KYC Service: $err', context);
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

    ref.listen(startOnboardingProvider, (_, value) {
      if (value is AsyncData) {
        openDojah();
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return SingleChildScrollView(
      child: Column(
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
            "Complete a few quick steps to get verified and start getting booked",
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall,
          ),
          32.0.height,
          onboardingStatus.when(
            data: (data) {
              return Column(
                children: [
                  for (var kycItem in [
                    (
                      AppImages.kyc,
                      'KYC Requirements',
                      data.steps?.kyc ?? 'not_started',
                      () {
                        if (data.steps?.kyc == 'completed') {
                          ToastDialog.showSuccess('KYC Verification Completed', context);
                        } else {
                          ref.read(startOnboardingProvider.notifier).startOnboarding();
                        }
                      }
                    ),
                    (
                      AppImages.bank,
                      'Payout Details',
                      data.steps?.payout ?? 'not_started',
                      () => context.push(const PayoutDetailsView()),
                    ),
                    (
                      AppImages.clipboard,
                      'Rates Card',
                      data.steps?.categories ?? 'not_started',
                      () => context.push(const RatesCardView()),
                    ),
                    (
                      AppImages.suitcase,
                      'Portfolio',
                      data.steps?.portfolio ?? 'not_started',
                      () => context.push(const PortfolioUploadView()),
                    ),
                    (
                      AppImages.calendarLine,
                      'Availability',
                      data.steps?.availability ?? 'not_started',
                      () => context.push(const SetAvailabilityView()),
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
                  32.0.height,
                  MainButton(
                    text:
                        (data.isOnboarded != true || data.completedAt == null) ? 'Start' : 'Continue',
                    isLoading: ref.watch(startOnboardingProvider).isLoading,
                    onPressed: () {
                      switch (data.nextStep) {
                        case 1:
                          ref.read(startOnboardingProvider.notifier).startOnboarding();
                          break;
                        case 2:
                          context.push(const PayoutDetailsView());
                          break;
                        case 3:
                          context.push(const RatesCardView());
                          break;
                        case 4:
                          context.push(const PortfolioUploadView());
                          break;
                        case 5:
                          if (data.steps?.portfolio == 'in_progress') {
                            context.push(const PortfolioUploadView());
                          } else {
                            context.push(const SetAvailabilityView());
                          }
                          break;
                        case 6:
                          context.pop();
                          break;
                        default:
                          break;
                      }
                    },
                  ),
                ],
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: CircularProgressIndicator.adaptive())),
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
      ),
    );
  }
}

class KycItem extends StatelessWidget {
  final String image, title, status;
  final VoidCallback? onTap;
  const KycItem({
    super.key,
    required this.image,
    required this.title,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.grey50,
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
                  'in_progress' => AppColors.yellow600,
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
                  'in_progress' => 'In Progress',
                  'pending' => 'Pending',
                  'not_started' => 'Not Started',
                  _ => 'Not Started',
                },
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
