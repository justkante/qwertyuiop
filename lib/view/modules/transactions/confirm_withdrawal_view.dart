import 'package:creatify_mobile/core/error/stripe_onboarding_exception.dart';
import 'package:creatify_mobile/data/models/requests/withdraw_req.dart';
import 'package:creatify_mobile/data/models/responses/bank_item_dto.dart';
import 'package:creatify_mobile/view/modules/authentication/enter_verification_sheet.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/reset_pin_vm.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/withdraw_wallet_vm.dart';
import 'package:creatify_mobile/view/modules/webview/app_webview.dart';
import 'package:creatify_mobile/view/modules/transactions/widgets/transaction_line.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
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
import 'package:pinput/pinput.dart';

class ConfirmWithdrawalView extends ConsumerStatefulWidget {
  final num? amount;
  final BankItemDto? selectedBank;
  final String? accountNumber;
  final String? accountName;
  const ConfirmWithdrawalView({
    super.key,
    this.amount,
    this.selectedBank,
    this.accountNumber,
    this.accountName,
  });

  @override
  ConsumerState<ConfirmWithdrawalView> createState() => _ConfirmWithdrawalViewState();
}

class _ConfirmWithdrawalViewState extends ConsumerState<ConfirmWithdrawalView> {
  final TextEditingController codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final withdrawing = ref.watch(withdrawWalletProvider).isLoading;
    final forgottingPin = ref.watch(forgotWalletPinProvider).isLoading;
    final userData = ref.watch(userControllerProvider);

    ref.listen(withdrawWalletProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();
        if (userData.primaryCurrency == 'NGN') {
          ToastDialog.showSuccess('Withdrawal Request has been Submitted', context);
        } else {
          ToastDialog.showSuccess(
              'Withdrawal request has been submitted to Stripe Dashboard', context);
        }
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
        if (value.error is StripeOnboardingException) {
          final onboardingData = (value.error as StripeOnboardingException).onboardingData;
          if (onboardingData.onboardingUrl != null) {
            context.push(
              WebviewScreen(
                url: onboardingData.onboardingUrl!,
                routeName: 'Stripe Onboarding',
              ),
            );
          }
        }
      }
    });

    ref.listen(forgotWalletPinProvider, (_, value) {
      if (value is AsyncData) {
        AppBottomSheet.showBottomSheet(
          context,
          widget: EnterVerificationCodeSheet(
            email: userData.email ?? '',
            route: VerificationRoute.forgotPin,
          ),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: withdrawing,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Confirm Withdrawal',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.subHeading,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              8.0.height,
              Center(
                child: SvgPicture.asset(
                  AppImages.withdrawal,
                  width: 80,
                  height: 80,
                ),
              ),
              12.0.height,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Review your withdrawal details below. Enter your PIN to complete this transaction.',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.body,
                  ),
                ),
              ),
              32.0.height,
              for (var details in [
                ('Amount', widget.amount?.amountWithCurrency(userData.primaryCurrency ?? '')),
                if (userData.primaryCurrency == 'NGN') ...{
                  ('Bank', widget.selectedBank?.name ?? 'GTBank'),
                  ('Account Number', widget.accountNumber ?? '0123456789'),
                  ('Account Name', widget.accountName ?? 'John Doe'),
                },
                ('Date', DateTime.now().toFormattedDateWithYear()),
              ])
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
                  child: TransactionLine(
                    title: details.$1,
                    value: details.$2,
                  ),
                ),
              16.0.height,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TransactionLine(
                  title: 'Final Amount',
                  valueColor: AppColors.highlightGreen,
                  value: widget.amount?.amountWithCurrency(userData.primaryCurrency ?? ''),
                ),
              ),
              32.0.height,
              Center(
                child: Text(
                  'Confirm Withdrawal PIN',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.subHeading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              12.0.height,
              Center(
                child: Pinput(
                  controller: codeController,
                  hapticFeedbackType: HapticFeedbackType.mediumImpact,
                  separatorBuilder: (index) => 24.0.width,
                  length: 4,
                  obscureText: true,
                  obscuringCharacter: '●',
                  defaultPinTheme: defaultPinInputTheme,
                  focusedPinTheme: focusedPinInputTheme,
                ),
              ),
              12.0.height,
              Center(
                child: InkWell(
                  onTap: () {
                    ref.read(forgotWalletPinProvider.notifier).forgotWalletPin();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot PIN?',
                        style: context.textTheme.bodySmall?.copyWith(color: AppColors.primary),
                      ),
                      if (forgottingPin) ...[
                        8.0.width,
                        LoadingAnimationWidget.hexagonDots(color: AppColors.primary, size: 12)
                      ]
                    ],
                  ),
                ),
              ),
              48.0.height,
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 2,
                    child: MainButton(
                      color: AppColors.highlightRed,
                      text: 'Cancel',
                      onPressed: () {
                        context.pop();
                      },
                    ),
                  ),
                  12.0.width,
                  Expanded(
                    flex: 3,
                    child: ValueListenableBuilder(
                      valueListenable: codeController,
                      builder: (context, value, child) {
                        bool isValid = value.text.length == 4;
                        return MainButton(
                          text: 'Confirm Withdrawal',
                          isLoading: withdrawing,
                          onPressed: isValid
                              ? () {
                                  ref.read(withdrawWalletProvider.notifier).withdrawWalletPayment(
                                        WithdrawReq(
                                          amount: widget.amount ?? 0,
                                          bankCode: (userData.primaryCurrency == 'NGN')
                                              ? widget.selectedBank?.code ?? ''
                                              : null,
                                          accountNumber: (userData.primaryCurrency == 'NGN')
                                              ? widget.accountNumber ?? ''
                                              : null,
                                          pin: codeController.text,
                                        ),
                                      );
                                }
                              : null,
                        );
                      },
                    ),
                  )
                ],
              ),
              24.0.height
            ],
          ),
        ),
      ),
    );
  }
}
