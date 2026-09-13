import 'package:creatify_mobile/data/models/requests/change_password_req.dart';
import 'package:creatify_mobile/view/modules/home/vm/change_password_vm.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChangePasswordView extends ConsumerStatefulWidget {
  const ChangePasswordView({super.key});

  @override
  ConsumerState<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends ConsumerState<ChangePasswordView> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Password Stuvs
  bool obscure = true;
  bool newObscure = true;
  bool confirmObscure = true;

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final changingPassword = ref.watch(changePasswordProvider).isLoading;

    ref.listen(changePasswordProvider, (_, value) {
      if (value is AsyncData) {
        Navigator.of(context).pop();
        ToastDialog.showSuccess('Password Successfully Changed', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return Form(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Change Password",
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
              16.0.height,
              TextInputField(
                header: 'Old Password',
                controller: oldPasswordController,
                hint: 'Enter Old Password',
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
                    color: AppColors.grey400,
                  ),
                ),
                validator: validatePassword,
              ),
              16.0.height,
              TextInputField(
                header: 'New Password',
                controller: newPasswordController,
                hint: 'Enter New Password',
                obscureText: newObscure,
                maxLines: 1,
                inputType: TextInputType.visiblePassword,
                autoCorrect: false,
                suffixIcon: InkWell(
                  onTap: () {
                    newObscure = !newObscure;
                    setState(() {});
                  },
                  child: Icon(
                    size: 22,
                    newObscure ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.grey400,
                  ),
                ),
                validator: validateFirstPassword,
              ),
              16.0.height,
              TextInputField(
                header: 'Confirm Password',
                controller: confirmPasswordController,
                hint: 'Confirm New Password',
                obscureText: confirmObscure,
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
                    confirmObscure ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.grey300,
                  ),
                ),
                validator: (value) {
                  return confirmPassword(
                    value,
                    newPasswordController.text,
                  );
                },
              ),
              16.0.height,
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListenableBuilder(
                    listenable: Listenable.merge([
                      oldPasswordController,
                      newPasswordController,
                      confirmPasswordController,
                    ]),
                    builder: (context, child) {
                      final isValid = validateRequiredFields([
                        oldPasswordController.text,
                        newPasswordController.text,
                        confirmPasswordController.text,
                      ]);

                      final passwordsMatch =
                          newPasswordController.text == confirmPasswordController.text;

                      return MainButton(
                        text: 'Change Password',
                        isLoading: changingPassword,
                        onPressed: isValid && passwordsMatch
                            ? () {
                                if (Form.of(context).validate()) {
                                  ref.read(changePasswordProvider.notifier).changePassword(
                                        ChangePasswordReq(
                                          currentPassword: oldPasswordController.text,
                                          newPassword: newPasswordController.text,
                                          newPasswordConfirmation: confirmPasswordController.text,
                                        ),
                                      );
                                }
                              }
                            : null,
                      );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
