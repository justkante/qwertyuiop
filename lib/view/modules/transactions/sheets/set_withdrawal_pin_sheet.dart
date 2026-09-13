import 'package:creatify_mobile/data/models/requests/create_wallet_pin_req.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/wallet_pin_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pinput/pinput.dart';

class SetWithdrawalPinSheet extends ConsumerStatefulWidget {
  const SetWithdrawalPinSheet({
    super.key,
  });

  @override
  ConsumerState<SetWithdrawalPinSheet> createState() => _EnterVerificationCodeSheetState();
}

class _EnterVerificationCodeSheetState extends ConsumerState<SetWithdrawalPinSheet> {
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
    final settingPin = ref.watch(createWalletPinProvider).isLoading;

    ref.listen(createWalletPinProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();
        ToastDialog.showSuccess('Withdrawal PIN successfully set', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: settingPin,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            16.0.height,
            Center(child: SvgPicture.asset(AppImages.secure)),
            16.0.height,
            Center(
              child: Text(
                'Secure Your Funds',
                textAlign: TextAlign.center,
                style: context.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            8.0.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                'Before you make your first withdrawal, please set a secure 4-digit PIN. This PIN will be required anytime you withdraw money from your Creatify wallet.',
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            32.0.height,

            // Enter PIN Input
            Text(
              'Enter 4-digit PIN',
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
                  text: 'Set PIN',
                  isLoading: settingPin,
                  onPressed: isCodeValid
                      ? () {
                          ref
                              .read(createWalletPinProvider.notifier)
                              .createWalletPin(CreateWalletPinReq(
                                pin: codeController.text,
                                confirmPin: confirmCodeController.text,
                              ));
                        }
                      : null,
                );
              },
            ),
            24.0.height,
          ],
        ),
      ),
    );
  }
}
