import 'package:creatify_mobile/view/modules/authentication/enter_verification_sheet.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/reset_pin_vm.dart';
import 'package:flutter/material.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pinput/pinput.dart';

class ResetTransactionPinView extends ConsumerStatefulWidget {
  const ResetTransactionPinView({
    super.key,
  });

  @override
  ConsumerState<ResetTransactionPinView> createState() => _EnterVerificationCodeSheetState();
}

class _EnterVerificationCodeSheetState extends ConsumerState<ResetTransactionPinView> {
  final TextEditingController codeController = TextEditingController();
  final TextEditingController confirmCodeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    confirmCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resettingWalletPin = ref.watch(resetWalletPinProvider).isLoading;

    ref.listen(resetWalletPinProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();
        ToastDialog.showSuccess('Transaction PIN has been reset!', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: resettingWalletPin,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Reset Transaction PIN",
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
            mainAxisSize: MainAxisSize.min,
            children: [
              16.0.height,

              // Enter PIN Input
              Text(
                'Enter new 4-digit PIN',
                style: context.textTheme.bodySmall?.copyWith(color: AppColors.subHeading),
                textAlign: TextAlign.left,
              ),
              6.0.height,
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
              18.0.height,
              Text(
                'Confirm 4-digit PIN',
                style: context.textTheme.bodySmall?.copyWith(color: AppColors.subHeading),
                textAlign: TextAlign.left,
              ),
              6.0.height,
              Center(
                child: Pinput(
                  controller: confirmCodeController,
                  hapticFeedbackType: HapticFeedbackType.mediumImpact,
                  separatorBuilder: (index) => 24.0.width,
                  length: 4,
                  obscureText: true,
                  obscuringCharacter: '●',
                  defaultPinTheme: defaultPinInputTheme,
                  focusedPinTheme: focusedPinInputTheme,
                  validator: (value) {
                    if (value != codeController.text) {
                      return 'PINs do not match';
                    }
                    return null;
                  },
                ),
              ),
              42.0.height,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  'Never share your PIN with anyone. For your security, Creatify will never ask for it.',
                  style: context.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              25.0.height,
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListenableBuilder(
                listenable: Listenable.merge([
                  codeController,
                  confirmCodeController,
                ]),
                builder: (context, _) {
                  final isCodeValid = codeController.text.length == 4 &&
                      codeController.text == confirmCodeController.text;
                  return MainButton(
                    color: AppColors.highlightBlue,
                    text: 'Reset PIN',
                    isLoading: resettingWalletPin,
                    onPressed: isCodeValid
                        ? () {
                            ref.read(resetWalletPinProvider.notifier).resetWalletPin(
                                otpCode: enteredCode.value, newPin: codeController.text);
                          }
                        : null,
                  );
                },
              ),
              24.0.height,
            ],
          ),
        ),
      ),
    );
  }
}
