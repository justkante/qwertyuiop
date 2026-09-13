import 'package:creatify_mobile/view/modules/authentication/signup_view.dart';
import 'package:creatify_mobile/view/modules/home/vm/delete_account_vm.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/delete_account_confirmation.dart';
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

class DeleteAccountView extends ConsumerStatefulWidget {
  const DeleteAccountView({super.key});

  @override
  ConsumerState<DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends ConsumerState<DeleteAccountView> {
  final passwordController = TextEditingController();

  // Password Stuvs
  bool obscure = true;

  bool acceptTerms = false;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authStrategy = ref.watch(userControllerProvider).authStrategy;

    final deleting = ref.watch(deleteAccountProvider).isLoading;

    ref.listen(deleteAccountProvider, (_, value) {
      if (value is AsyncData) {
        context.pushAndRemoveUntil(const SignupView());

        ToastDialog.showSuccess(
            'Your account has been deleted successfully. Creatify will miss you!', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delete Account',
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.subHeading,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            12.0.height,
            Text(
              authStrategy != 'email'
                  ? """
Deleting your account will permanently remove your profile, bookings, messages, and saved data from Creatify.

This action cannot be undone. Please make sure you’ve withdrawn any available funds and saved anything important before continuing. 

You can create a new account in the future, but your previous data will not be recoverable."""
                  : """
Deleting your account will permanently remove your profile, bookings, messages, and data from Creatify. This action cannot be undone.

Please ensure you have:
	•	Withdrawn any available funds
	•	Resolved or completed any active bookings
""",
              style: context.textTheme.bodySmall,
            ),
            4.0.height,

            // Only ask for password if auth strategy is email
            if (authStrategy == 'email') ...[
              TextInputField(
                controller: passwordController,
                autoCorrect: false,
                header: 'Account Password',
                hint: 'Enter Password',
                obscureText: obscure,
                maxLines: 1,
                inputType: TextInputType.visiblePassword,
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
              12.0.height,
            ],

            // Accept Terms and Conditions
            12.0.height,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: acceptTerms,
                  onChanged: (value) {
                    setState(() {
                      acceptTerms = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                6.0.width,
                Expanded(
                  child: Text(
                    'I understand that deleting my account is permanent and all my data will be permanently removed. I have withdrawn any available funds and saved important information before proceeding.',
                    style: context.textTheme.bodySmall?.copyWith(color: AppColors.highlightCoral),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListenableBuilder(
              listenable: Listenable.merge([passwordController]),
              builder: (context, child) {
                bool isEmailStrategyValid = (validatePassword(passwordController.text) == null);

                bool isOtherStrategyValid = acceptTerms;
                return MainButton(
                  text: 'Delete Account',
                  isLoading: deleting,
                  color: AppColors.highlightRed,
                  onPressed: (((authStrategy == 'email') && isEmailStrategyValid) ||
                              ((authStrategy != 'email') && isOtherStrategyValid)) &&
                          acceptTerms
                      ? () async {
                          bool? result = await AppBottomSheet.showBottomSheet(
                            context,
                            widget: const DeleteAccountConfirmation(),
                          );

                          if (result != null && result) {
                            ref
                                .read(deleteAccountProvider.notifier)
                                .deleteAccount(password: passwordController.text);
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
    );
  }
}
