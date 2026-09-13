import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InsufficientFundSheet extends ConsumerStatefulWidget {
  const InsufficientFundSheet({
    super.key,
  });

  @override
  ConsumerState<InsufficientFundSheet> createState() => _EnterVerificationCodeSheetState();
}

class _EnterVerificationCodeSheetState extends ConsumerState<InsufficientFundSheet> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        16.0.height,
        SvgPicture.asset(AppImages.handWallet),
        16.0.height,
        Text(
          'Insufficient Wallet Balance',
          style: context.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        16.0.height,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            'You don’t have enough funds to send this booking request. Please top up your wallet to continue.',
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        48.0.height,
        MainButton(
          text: 'Fund Wallet',
          isLoading: false,
          onPressed: () {},
        ),
        48.0.height,
      ],
    );
  }
}
