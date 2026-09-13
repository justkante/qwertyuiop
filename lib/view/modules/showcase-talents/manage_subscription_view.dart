import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/cancel_subscriotion_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/make_subscription_payment_vm.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ManageSubscriptionView extends ConsumerStatefulWidget {
  const ManageSubscriptionView({super.key});

  @override
  ConsumerState<ManageSubscriptionView> createState() => _ManageSubscriptionViewState();
}

class _ManageSubscriptionViewState extends ConsumerState<ManageSubscriptionView> {
  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final subscriptionDetails = ref.watch(fetchMySubscriptionProvider);

    ref.listen(autoRenewSubscriptionProvider, (_, value) {
      if (value is AsyncData) {}
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Subscription',
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.subHeading,
          ),
        ),
      ),
      body: subscriptionDetails.when(
        data: (data) {
          bool autoRenew = data.data?.autoRenew ?? false;

          if (data.data == null) {
            return Center(
              child: Text(
                "You do not have an active subscription plan at the moment.",
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.subHeading,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // MARK: Current Plan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.highlightBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // MARK: Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Current Plan',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        AppImages.indicator,
                                        colorFilter: data.isActive == true
                                            ? AppColors.highlightGreen.colorFilterMode()
                                            : AppColors.highlightRed.colorFilterMode(),
                                        width: 6,
                                        height: 6,
                                      ),
                                      4.0.width,
                                      Text(
                                        data.isActive == true ? 'Active' : 'Inactive',
                                        style: context.textTheme.bodySmall?.copyWith(
                                          color: data.isActive == true
                                              ? AppColors.highlightGreen
                                              : AppColors.highlightRed,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // MARK: Plan Details
                            16.0.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${data.data?.plan?.name} Plan',
                                      style: context.textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        color: Colors.white.withValues(alpha: 0.5),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    3.0.height,
                                    Text(
                                      num.tryParse(data.data?.amount ?? '0')
                                          .amountWithCurrency(userData.primaryCurrency ?? ''),
                                      style: context.textTheme.headlineSmall?.copyWith(
                                        fontSize: 21,
                                        fontFamily: FontFamily.inter,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Expiry Date',
                                      style: context.textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        color: Colors.white.withValues(alpha: 0.5),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    3.0.height,
                                    Text(
                                      data.data?.expiresAt?.toFormattedDateWithYear() ?? '',
                                      style: context.textTheme.headlineSmall?.copyWith(
                                        fontSize: 21,
                                        fontFamily: FontFamily.inter,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            16.0.height,
                          ],
                        ),
                      ),

                      // MARK: Auto Renew Toggle
                      16.0.height,
                      Visibility(
                        visible: false,
                        child: Row(
                          children: [
                            Switch(
                              value: autoRenew,
                              onChanged: (value) {
                                setState(() {
                                  autoRenew = value;
                                });

                                ref
                                    .read(autoRenewSubscriptionProvider.notifier)
                                    .toggleAutoRenewSubscription(
                                      id: data.data?.id ?? '',
                                      autoRenew: value,
                                    );
                              },
                              activeThumbColor: Colors.white,
                              inactiveTrackColor: AppColors.grey200,
                              activeTrackColor: AppColors.primary,
                            ),
                            8.0.width,
                            Text(
                              'Auto Renew',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.black2,
                              ),
                            ),
                            if (ref.watch(autoRenewSubscriptionProvider).isLoading) ...[
                              8.0.width,
                              LoadingAnimationWidget.hexagonDots(color: AppColors.black2, size: 16),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Cancel Subscription Button
                MainButton(
                  text: 'Cancel Subscription',
                  onPressed: () {
                    AppBottomSheet.showBottomSheet(
                      context,
                      widget: CancelSubscriptionSheet(
                        subscriptionId: data.data?.id,
                      ),
                    );
                  },
                ),
                48.0.height,
              ],
            ),
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
              const Text('Loading Subscription Details...'),
            ],
          ),
        ),
        error: (error, stackTrace) => Text('Error: $error'),
      ),
    );
  }
}
