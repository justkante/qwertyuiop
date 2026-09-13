import 'package:creatify_mobile/data/models/requests/change_wallet_pin_req.dart';
import 'package:flutter/material.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/wallet_pin_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pinput/pinput.dart';

class ChangeTransactionPinView extends ConsumerStatefulWidget {
  const ChangeTransactionPinView({
    super.key,
  });

  @override
  ConsumerState<ChangeTransactionPinView> createState() => _EnterVerificationCodeSheetState();
}

class _EnterVerificationCodeSheetState extends ConsumerState<ChangeTransactionPinView> {
  final TextEditingController currentCodeController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController confirmCodeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    confirmCodeController.dispose();
    currentCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final changingWalletPin = ref.watch(changeWalletPinProvider).isLoading;

    ref.listen(changeWalletPinProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();
        ToastDialog.showSuccess('Transaction PIN successfully changed', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: changingWalletPin,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Change Transaction PIN",
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
                'Enter Current 4-digit PIN',
                style: context.textTheme.bodySmall?.copyWith(color: AppColors.subHeading),
                textAlign: TextAlign.left,
              ),
              6.0.height,
              Center(
                child: Pinput(
                  controller: currentCodeController,
                  hapticFeedbackType: HapticFeedbackType.mediumImpact,
                  separatorBuilder: (index) => 24.0.width,
                  length: 4,
                  obscureText: true,
                  obscuringCharacter: '●',
                  defaultPinTheme: defaultPinInputTheme,
                  focusedPinTheme: focusedPinInputTheme,
                ),
              ),
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
                  currentCodeController,
                  codeController,
                  confirmCodeController,
                ]),
                builder: (context, _) {
                  final isCodeValid = currentCodeController.text.length == 4 &&
                      codeController.text.length == 4 &&
                      codeController.text == confirmCodeController.text;
                  return MainButton(
                    color: AppColors.highlightBlue,
                    text: 'Change PIN',
                    isLoading: changingWalletPin,
                    onPressed: isCodeValid
                        ? () {
                            ref.read(changeWalletPinProvider.notifier).changeWalletPin(
                                  ChangeWalletPinReq(
                                    oldPin: currentCodeController.text,
                                    newPin: codeController.text,
                                    confirmNewPin: confirmCodeController.text,
                                  ),
                                );
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
