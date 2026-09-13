import 'package:creatify_mobile/data/models/responses/make_subcription_payment_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/make_subscription_payment_vm.dart';
import 'package:creatify_mobile/view/modules/webview/app_webview.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UpgradeAccountSheet extends ConsumerStatefulWidget {
  const UpgradeAccountSheet({super.key});

  @override
  ConsumerState<UpgradeAccountSheet> createState() => _UpgradeAccountSheetState();
}

class _UpgradeAccountSheetState extends ConsumerState<UpgradeAccountSheet> {
  String selectedPlan = '';
  String? selectedPlanId;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final availablePlans = ref.watch(fetchSubscriptionPlansProvider);

    ref.listen(makeSubscriptionPaymentProvider, (_, value) {
      if (value is AsyncData<MakeSubcriptionPaymentDto>) {
        context.pop();
        context.push(
          WebviewScreen(
            url: value.value.authorizationUrl ?? '',
            paymentReference: value.value.paymentReference,
            routeName: 'Subscription Payment',
          ),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        12.0.height,
        SvgPicture.asset(
          AppImages.premium,
          width: 115,
          height: 80,
        ),
        8.0.height,

        // MARK: Title
        Text(
          'Upgrade to Creatify Premium',
          style: context.textTheme.headlineSmall?.copyWith(fontSize: 19),
        ),
        6.0.height,
        Text(
          "Stand out from the crowd and unlock powerful tools to grow your creative career. Choose the plan that works best for you and start enjoying premium benefits today",
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        32.0.height,

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var details in [
                (AppImages.eye, "Spotlight your profile to increase visibility"),
                (AppImages.searchLight, 'Get priority placement in recruiter searches'),
                (AppImages.cancel, 'Cancel anytime, no hidden fees'),
              ])
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(details.$1, width: 20, height: 20),
                      12.0.width,
                      Expanded(
                          child: Text(
                        details.$2,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.subHeading,
                        ),
                      )),
                    ],
                  ),
                )
            ],
          ),
        ),
        32.0.height,

        // MARK: Plan Selector
        availablePlans.when(
          data: (plans) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPlan = 'monthly';
                        selectedPlanId = plans.first.id;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedPlan == 'monthly'
                              ? AppColors.highlightCoral
                              : AppColors.surface,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Monthly',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color:
                                      selectedPlan == 'monthly' ? AppColors.black2 : AppColors.body,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SvgPicture.asset(
                                selectedPlan == 'monthly'
                                    ? AppImages.radioFilled
                                    : AppImages.radioOutline,
                              ),
                            ],
                          ),
                          32.0.height,
                          Text(
                            num.tryParse(plans.first.amount ?? '0')
                                .amountWithCurrency(userData.primaryCurrency ?? ''),
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontSize: 19,
                              fontFamily: FontFamily.inter,
                              color: selectedPlan == 'monthly'
                                  ? AppColors.highlightBlue
                                  : AppColors.subHeading,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                12.0.width,
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPlan = 'annual';
                        selectedPlanId = plans.last.id;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedPlan == 'annual'
                              ? AppColors.highlightCoral
                              : AppColors.surface,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Annual',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color:
                                      selectedPlan == 'annual' ? AppColors.black2 : AppColors.body,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SvgPicture.asset(
                                selectedPlan == 'annual'
                                    ? AppImages.radioFilled
                                    : AppImages.radioOutline,
                              ),
                            ],
                          ),
                          32.0.height,
                          Text(
                            num.tryParse(plans.last.amount ?? '0')
                                .amountWithCurrency(userData.primaryCurrency ?? ''),
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontSize: 19,
                              fontFamily: FontFamily.inter,
                              color: selectedPlan == 'annual'
                                  ? AppColors.highlightBlue
                                  : AppColors.subHeading,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
                8.0.height,
                const Text('Loading Plans'),
              ],
            ),
          ),
          error: (error, stackTrace) => Text('Error: $error'),
        ),
        40.0.height,

        MainButton(
          text: 'Upgrade Now',
          isLoading: ref.watch(makeSubscriptionPaymentProvider).isLoading,
          onPressed: selectedPlanId == null
              ? null
              : () {
                  ref
                      .read(makeSubscriptionPaymentProvider.notifier)
                      .makeSubscriptionPayment(selectedPlanId ?? '');
                },
        ),
        16.0.height,
      ],
    );
  }
}
