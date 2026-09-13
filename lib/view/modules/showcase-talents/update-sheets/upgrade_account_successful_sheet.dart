import 'package:creatify_mobile/view/modules/showcase-talents/vm/make_subscription_payment_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UpgradeAccountSuccessfulSheet extends ConsumerStatefulWidget {
  const UpgradeAccountSuccessfulSheet({super.key});

  @override
  ConsumerState<UpgradeAccountSuccessfulSheet> createState() => _UpgradeAccountSheetState();
}

class _UpgradeAccountSheetState extends ConsumerState<UpgradeAccountSuccessfulSheet> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Upgrade Successful',
          style: context.textTheme.headlineSmall?.copyWith(fontSize: 19),
        ),
        6.0.height,
        Text(
          "Welcome to Creatify Premium! Your account has been upgraded, and you now have access to exclusive benefits designed to help you shine brighter and book more opportunities",
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),

        40.0.height,

        MainButton(
          text: 'Go to My Account',
          isLoading: ref.watch(makeSubscriptionPaymentProvider).isLoading,
          onPressed: () {
            context.pop();
          },
        ),
        24.0.height,
      ],
    );
  }
}
