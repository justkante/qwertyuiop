import 'dart:developer';

import 'package:creatify_mobile/data/models/responses/fund_wallet_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/stripe_init.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/wallet_funding_vm.dart';
import 'package:creatify_mobile/view/modules/webview/app_webview.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/thousands_formatter.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class FundWalletSheet extends ConsumerStatefulWidget {
  const FundWalletSheet({
    super.key,
  });

  @override
  ConsumerState<FundWalletSheet> createState() => _EnterVerificationCodeSheetState();
}

class _EnterVerificationCodeSheetState extends ConsumerState<FundWalletSheet> {
  final TextEditingController amount = TextEditingController();

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final funding = ref.watch(fundWalletProvider).isLoading;
    final userData = ref.watch(userControllerProvider);

    ref.listen(fundWalletProvider, (_, next) async {
      if (next is AsyncData<FundWalletDto>) {
        if (userData.countryCode == 'NG') {
          context.pop();

          NavigationService.instance.push(
            WebviewScreen(
              url: next.value.authorizationUrl ?? '',
              routeName: 'Fund Wallet',
              paymentReference: next.value.reference ?? '',
            ),
          );
        } else {
          // Initialize Stripe First
          await initStripePayment(
            paymentIntent: next.value.stripePaymentIntentId ?? '',
            clientSecret: next.value.clientSecret ?? '',
            context: context,
          ).then((value) async {
            // Show the Payment Sheet
            await Stripe.instance.presentPaymentSheet().then((val) {
              if (context.mounted) {
                log('Payment successful for reference: ${next.value.reference}');
                // Pop the Screen and refresh Balance and Transactions if successful
                context.pop();
                ToastDialog.showSuccess('Your funding was successful', context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref
                      .read(verifyWalletFundingProvider.notifier)
                      .verifyFundingPayment(next.value.reference ?? '');
                });
              }
            });
          });
        }
      }
      if (next is AsyncError) {
        if (context.mounted) {
          ToastDialog.showError(next.error.toString(), context);
        }
      }
    });

    return AbsorbPointer(
      absorbing: funding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          16.0.height,
          SvgPicture.asset(AppImages.handWallet),
          16.0.height,
          Text(
            'Fund Your Wallet',
            style: context.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 28), // Increased
          ),
          8.0.height,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Text(
              'Enter the amount you want to add to your wallet. Funds will be available instantly after payment.',
              style: context.textTheme.bodySmall?.copyWith(fontSize: 14), // Increased
              textAlign: TextAlign.center,
            ),
          ),
          32.0.height,
          TextInputField(
            header: 'Amount',
            headerStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), // Increased
            controller: amount,
            inputType: TextInputType.number,
            style: const TextStyle(fontSize: 18), // Increased
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              LengthLimitingTextInputFormatter(17),
              ThousandsFormatter(
                allowFraction: true,
                formatter: NumberFormat.decimalPattern(),
              ),
            ],
            hint: 'Enter Amount',
            hintStyle: const TextStyle(fontSize: 16), // Increased
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              } else if (((double.tryParse(value.removeCommas()) ?? 0) < 1000) &&
                  userData.countryCode == 'NG') {
                return 'Amount cannot be less than ${1000.amountWithCurrency(userData.primaryCurrency ?? '')}';
              } else if (((double.tryParse(value.removeCommas()) ?? 0) < 5) &&
                  userData.countryCode != 'NG') {
                return 'Amount cannot be less than ${5.amountWithCurrency(userData.primaryCurrency ?? '')}';
              }
              return null;
            },
          ),
          42.0.height,
          25.0.height,
          ListenableBuilder(
            listenable: Listenable.merge([amount]),
            builder: (context, _) {
              final isCodeValid = validateRequiredFields([amount.text]) &&
                  ((num.tryParse(amount.text.replaceAll(',', '')) ?? 0) >=
                      (userData.countryCode == 'NG' ? 1000 : 5));

              return MainButton(
                text: 'Fund Wallet',
                isLoading: funding,
                fontSize: 18, // Increased
                padding: const EdgeInsets.symmetric(vertical: 16), // Increased
                onPressed: isCodeValid
                    ? () {
                        ref.read(fundWalletProvider.notifier).fundWallet(
                              num.tryParse(amount.text.replaceAll(',', '')) ?? 0,
                            );
                      }
                    : null,
              );
            },
          ),
          24.0.height,
        ],
      ),
    );
  }
}
