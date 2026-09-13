import 'package:creatify_mobile/data/models/requests/verify_email_req.dart';
import 'package:creatify_mobile/view/modules/authentication/account_created_sheet.dart';
import 'package:creatify_mobile/view/modules/authentication/forgot-password/reset_password_view.dart';
import 'package:creatify_mobile/view/modules/authentication/forgot-password/vm/forgot_password_email_vm.dart';
import 'package:creatify_mobile/view/modules/authentication/vm/verify_email_vm.dart';
import 'package:creatify_mobile/view/modules/transactions/reset_pin_view.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/reset_pin_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pinput/pinput.dart';

ValueNotifier<String> enteredCode = ValueNotifier('');
ValueNotifier<String> enteredEmail = ValueNotifier('');

enum VerificationRoute { signUp, forgotPassword, forgotPin }

class EnterVerificationCodeSheet extends ConsumerStatefulWidget {
  final String email;
  final VerificationRoute route;
  const EnterVerificationCodeSheet({
    super.key,
    required this.email,
    this.route = VerificationRoute.signUp,
  });

  @override
  ConsumerState<EnterVerificationCodeSheet> createState() => _EnterVerificationCodeSheetState();
}

class _EnterVerificationCodeSheetState extends ConsumerState<EnterVerificationCodeSheet> {
  final TextEditingController codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verifying = ref.watch(verifyEmailProvider).isLoading;
    final resending = ref.watch(resendVerifyEmailProvider).isLoading;
    final forgotResending = ref.watch(resendForgotPasswordEmailProvider).isLoading;
    final forgotVerifying = ref.watch(verifyForgotEmailProvider).isLoading;
    final forgotPinVerifying = ref.watch(verifyForgotWalletPinProvider).isLoading;
    final forgotWalletPinResending = ref.watch(resendForgotWalletPinProvider).isLoading;

    ref.listen(verifyEmailProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();

        AppBottomSheet.showBottomSheet(
          context,
          isDismissible: false,
          enableDrag: false,
          widget: const AccountCreatedSheet(),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    ref.listen(verifyForgotEmailProvider, (_, value) {
      if (value is AsyncData) {
        setState(() {
          enteredEmail.value = widget.email;
          enteredCode.value = codeController.text;
        });

        context.pop();

        context.push(const ResetPasswordView());
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    ref.listen(verifyForgotWalletPinProvider, (_, value) {
      if (value is AsyncData) {
        setState(() {
          enteredCode.value = codeController.text;
        });

        context.pop();
        context.push(const ResetTransactionPinView());
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    ref.listen(resendVerifyEmailProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('Verification Code has been Resent', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    ref.listen(resendForgotPasswordEmailProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('Verification Code has been Resent', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    ref.listen(resendForgotWalletPinProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('Verification Code has been Resent', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: verifying || resending || forgotVerifying || forgotResending,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          16.0.height,
          Image.asset(
            AppImages.logo,
            width: 72,
            height: 72,
          ),
          16.0.height,
          Text(
            'Enter Verification Code',
            style: context.textTheme.displayMedium,
          ),
          8.0.height,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: RichText(
              text: TextSpan(
                text: "We've sent a 6-digit code to your email ",
                style: context.textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: widget.email.maskEmail(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.highlightCoral,
                        ),
                  ),
                  TextSpan(
                    text: '. Enter it below',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          25.0.height,
          Pinput(
            controller: codeController,
            hapticFeedbackType: HapticFeedbackType.mediumImpact,
            length: 6,
            obscureText: false,
            //obscuringCharacter: '●',
            defaultPinTheme: defaultPinInputTheme,
            focusedPinTheme: focusedPinInputTheme,
            validator: validatePin,
          ),
          25.0.height,
          Center(
            child: RichText(
              text: TextSpan(
                text: "Didn’t get the code? ",
                style: context.textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: 'Resend Code',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        switch (widget.route) {
                          case VerificationRoute.signUp:
                            ref
                                .read(resendVerifyEmailProvider.notifier)
                                .resendVerifyEmail(email: widget.email);
                            break;
                          case VerificationRoute.forgotPassword:
                            ref
                                .read(resendForgotPasswordEmailProvider.notifier)
                                .resendResetPasswordCode(email: widget.email);
                            break;
                          case VerificationRoute.forgotPin:
                            ref
                                .read(resendForgotWalletPinProvider.notifier)
                                .resendForgotWalletPin();
                            break;
                        }
                      },
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          25.0.height,
          ListenableBuilder(
            listenable: Listenable.merge([codeController]),
            builder: (context, _) {
              final isCodeValid = codeController.text.length == 6;
              return MainButton(
                text: 'Verify Email',
                isLoading: verifying ||
                    resending ||
                    forgotVerifying ||
                    forgotResending ||
                    forgotPinVerifying ||
                    forgotWalletPinResending,
                onPressed: isCodeValid
                    ? () {
                        switch (widget.route) {
                          case VerificationRoute.signUp:
                            ref.read(verifyEmailProvider.notifier).verifyEmail(
                                  VerifyEmailReq(
                                    email: widget.email,
                                    otpCode: codeController.text,
                                  ),
                                );
                            break;
                          case VerificationRoute.forgotPassword:
                            ref.read(verifyForgotEmailProvider.notifier).verifyForgotEmail(
                                  VerifyEmailReq(
                                    email: widget.email,
                                    otpCode: codeController.text,
                                  ),
                                );
                            break;
                          case VerificationRoute.forgotPin:
                            ref
                                .read(verifyForgotWalletPinProvider.notifier)
                                .verifyWalletPin(codeController.text);
                            break;
                        }
                      }
                    : null,
              );
            },
          ),
          40.0.height,
        ],
      ),
    );
  }
}
