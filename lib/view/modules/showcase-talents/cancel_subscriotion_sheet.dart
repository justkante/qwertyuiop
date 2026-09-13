import 'package:creatify_mobile/view/modules/showcase-talents/vm/make_subscription_payment_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CancelSubscriptionSheet extends ConsumerStatefulWidget {
  final String? subscriptionId;
  const CancelSubscriptionSheet({super.key, this.subscriptionId});

  @override
  ConsumerState<CancelSubscriptionSheet> createState() => _CancelSubscriptionSheetState();
}

class _CancelSubscriptionSheetState extends ConsumerState<CancelSubscriptionSheet> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(cancelSubscriptionProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();
        ToastDialog.showSuccess(
            'Subscription will be cancelled at the end of the current billing period', context);
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
        16.0.height,

        // MARK: Title
        Text(
          'Cancel Subscription?',
          style: context.textTheme.headlineSmall?.copyWith(fontSize: 19),
        ),
        6.0.height,
        Text(
          "Cancelling your subscription means losing access to premium boosts that help you get discovered faster and booked more often. Are you sure you want to continue?",
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        32.0.height,

        Row(
          children: [
            Expanded(
              flex: 5,
              child: MainButton(
                color: AppColors.highlightRed50,
                text: 'Back',
                textColor: AppColors.btnText,
                onPressed: () {
                  context.pop();
                },
              ),
            ),
            12.0.width,
            Expanded(
              flex: 6,
              child: MainButton(
                color: AppColors.kErrorColor,
                text: 'Yes, Cancel',
                isLoading: ref.watch(cancelSubscriptionProvider).isLoading,
                onPressed: () {
                  ref.read(cancelSubscriptionProvider.notifier).cancelSubscription(
                        widget.subscriptionId ?? '',
                      );
                },
              ),
            ),
          ],
        ),
        64.0.height,
      ],
    );
  }
}
