import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/view/modules/authentication/enter_verification_sheet.dart';
import 'package:creatify_mobile/view/modules/authentication/forgot-password/vm/forgot_password_email_vm.dart';
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

class ForgotPasswordEmailView extends ConsumerStatefulWidget {
  const ForgotPasswordEmailView({super.key});

  @override
  ConsumerState<ForgotPasswordEmailView> createState() => _ForgotPasswordEmailViewState();
}

class _ForgotPasswordEmailViewState extends ConsumerState<ForgotPasswordEmailView> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailController.text = SharedPrefManager.email;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forgotEmailLoading = ref.watch(forgotPasswordEmailProvider).isLoading;

    ref.listen(forgotPasswordEmailProvider, (_, value) {
      if (value is AsyncData) {
        AppBottomSheet.showBottomSheet(
          context,
          widget: EnterVerificationCodeSheet(
            email: emailController.text,
            route: VerificationRoute.forgotPassword,
          ),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: forgotEmailLoading,
      child: Form(
        key: _formKey,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: context.canPop,
            title: Text(
              'Forgot Password?',
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
                  "Enter the email address linked to your Creatify account and we'll send you a code to reset your password",
                  style: context.textTheme.bodySmall,
                ),
                20.0.height,
                TextInputField(
                  controller: emailController,
                  header: 'Email',
                  hint: 'Enter Email Address',
                  inputType: TextInputType.emailAddress,
                  autoCorrect: false,
                  validator: validateEmail,
                ),
                16.0.height,
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsetsGeometry.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListenableBuilder(
                  listenable: Listenable.merge([emailController]),
                  builder: (context, _) {
                    bool isValid = validateRequiredFields([emailController.text]);
                    return MainButton(
                      text: 'Reset Password',
                      isLoading: forgotEmailLoading,
                      onPressed: isValid
                          ? () {
                              if (_formKey.currentState?.validate() ?? false) {
                                ref
                                    .read(forgotPasswordEmailProvider.notifier)
                                    .verifyForgotEmail(email: emailController.text);
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
