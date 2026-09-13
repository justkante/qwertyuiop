import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/initialize_payment_vm.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/transactions_providers.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MakePaymentOptionsSheet extends ConsumerStatefulWidget {
  final num amountDue;
  final String bookingId;
  const MakePaymentOptionsSheet({super.key, required this.amountDue, required this.bookingId});

  @override
  ConsumerState<MakePaymentOptionsSheet> createState() => _MakePaymentOptionsSheetState();
}

class _MakePaymentOptionsSheetState extends ConsumerState<MakePaymentOptionsSheet> {
  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Choose Payment Method',
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.black2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Content
          ListTile(
            leading: SvgPicture.asset(
              AppImages.onlinePayment,
              width: 24,
              height: 24,
              colorFilter: AppColors.black2.colorFilterMode(),
            ),
            title: Text(
              'Pay Online',
              style: context.textTheme.bodyMedium?.copyWith(color: AppColors.black2),
            ),
            onTap: () {
              // Handle card payment option
              context.pop('online');

              ref
                  .read(initializePaymentProvider.notifier)
                  .initializePayment(widget.bookingId, 'online');
            },
          ),
          ListTile(
            leading: SvgPicture.asset(
              AppImages.walletFull,
              width: 24,
              height: 24,
              colorFilter: AppColors.black2.colorFilterMode(),
            ),
            title: Text(
              'Pay with Wallet',
              style: context.textTheme.bodyMedium?.copyWith(color: AppColors.black2),
            ),
            subtitle: Text(
              'Available Balance: ${ref.watch(walletBalanceProvider).amountWithCurrency(userData.primaryCurrency ?? '')}',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.btnText,
                fontFamily: FontFamily.inter,
              ),
            ),
            onTap: () {
              // Amount Due should be less than or equal to wallet balance
              if (widget.amountDue <= ref.watch(walletBalanceProvider)) {
                // Handle wallet payment option
                context.pop('wallet');

                ref
                    .read(initializePaymentProvider.notifier)
                    .initializePayment(widget.bookingId, 'wallet');
              } else {
                // Show error message
                ToastDialog.showError('Insufficient Balance', context);
              }
            },
          ),
        ],
      ),
    );
  }
}
