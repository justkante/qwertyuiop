import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/requests/reset_password_req.dart';
import 'package:creatify_mobile/view/modules/authentication/enter_verification_sheet.dart';
import 'package:creatify_mobile/view/modules/authentication/forgot-password/password_reset_sheet.dart';
import 'package:creatify_mobile/view/modules/authentication/forgot-password/vm/reset_password_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ResetPasswordView extends ConsumerStatefulWidget {
  const ResetPasswordView({super.key});

  @override
  ConsumerState<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends ConsumerState<ResetPasswordView> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Password Stuvs
  bool obscure = true;
  bool confirmObscure = true;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resetting = ref.watch(resetPasswordProvider).isLoading;

    ref.listen(resetPasswordProvider, (_, value) {
      if (value is AsyncData) {
        AppBottomSheet.showBottomSheet(
          context,
          isDismissible: false,
          enableDrag: false,
          widget: const PasswordResetSheet(),
        );

        setState(() {
          SharedPrefManager.email = enteredEmail.value;
        });
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: resetting,
      child: Form(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: context.canPop,
            title: Text(
              'Reset Password',
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.subHeading,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                Text(
                  "Your email has been confirmed. You can now set a new password to regain access to your account",
                  style: context.textTheme.bodySmall,
                ),
                20.0.height,
                TextInputField(
                  controller: passwordController,
                  header: 'Password',
                  hint: 'Create Password',
                  obscureText: obscure,
                  maxLines: 1,
                  inputType: TextInputType.visiblePassword,
                  autoCorrect: false,
                  suffixIcon: InkWell(
                    onTap: () {
                      obscure = !obscure;
                      setState(() {});
                    },
                    child: Icon(
                      size: 22,
                      obscure ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.grey300,
                    ),
                  ),
                  validator: validateFirstPassword,
                ),
                16.0.height,
                TextInputField(
                  controller: confirmPasswordController,
                  header: 'Confirm Password',
                  hint: 'Enter Password',
                  obscureText: obscure,
                  maxLines: 1,
                  inputType: TextInputType.visiblePassword,
                  autoCorrect: false,
                  suffixIcon: InkWell(
                    onTap: () {
                      confirmObscure = !confirmObscure;
                      setState(() {});
                    },
                    child: Icon(
                      size: 22,
                      obscure ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.grey300,
                    ),
                  ),
                  validator: validateFirstPassword,
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsetsGeometry.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListenableBuilder(
                  listenable: Listenable.merge([
                    passwordController,
                    confirmPasswordController,
                  ]),
                  builder: (context, _) {
                    bool isPasswordsMatch =
                        passwordController.text == confirmPasswordController.text;
                    bool isValid = validateRequiredFields(
                      [
                        passwordController.text,
                        confirmPasswordController.text,
                      ],
                    );
                    return MainButton(
                      text: 'Reset Password',
                      isLoading: resetting,
                      onPressed: (isValid && isPasswordsMatch)
                          ? () {
                              if (Form.of(context).validate()) {
                                ref.read(resetPasswordProvider.notifier).resetPassword(
                                      ResetPasswordReq(
                                        email: enteredEmail.value,
                                        otpCode: enteredCode.value,
                                        password: passwordController.text,
                                        passwordConfirmation: confirmPasswordController.text,
                                      ),
                                    );
                              }
                            }
                          : null,
                    );
                  },
                ),
                12.0.height,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
