import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/update_profile_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({super.key});

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _referrerCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  bool referralCodeEditted = false;
  bool emailEditted = false;
  bool hasUsedReferrerCode = false;
  String _initialReferrerCode = '';
  String _initialEmail = '';

  @override
  void initState() {
    super.initState();
    final userData = ref.read(userControllerProvider);
    _fullNameController.text = userData.name ?? '';
    _initialEmail = userData.email ?? '';
    _emailController.text = _initialEmail;
    _initialReferrerCode = userData.referredByCode ?? '';
    _referrerCodeController.text = _initialReferrerCode;
    _countryController.text = "${userData.countryFlag} ${userData.countryCode}";
    hasUsedReferrerCode = userData.hasUsedReferralCode ?? false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _referrerCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applyingCode = ref.watch(updateProfileProvider).isLoading;

    ref.listen(updateProfileProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();
        ToastDialog.showSuccess('Profile updated successfully!', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: applyingCode,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit Profile',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.subHeading,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Form
              TextInputField(
                header: 'Full Name',
                controller: _fullNameController,
                hint: 'Enter your full name',
                inputType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                readOnly: true,
                maxLines: 1,
                validator: validateGeneric,
              ),
              4.0.height,
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Full name cannot be changed',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.body,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              18.0.height,
              TextInputField(
                header: 'Email',
                controller: _emailController,
                hint: 'Enter your email address',
                inputType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                readOnly: false, // Editable!
                maxLines: 1,
                onChanged: (value) {
                  setState(() => emailEditted = value != _initialEmail);
                },
                validator: validateEmail,
              ),
              18.0.height,
              TextInputField(
                header: 'Referrer Code',
                controller: _referrerCodeController,
                hint: 'Enter code',
                inputType: TextInputType.text,
                readOnly: hasUsedReferrerCode,
                onChanged: (value) {
                  setState(() => referralCodeEditted = value != _initialReferrerCode);
                },
                textCapitalization: TextCapitalization.characters,
                validator: validateGeneric,
              ),
              4.0.height,
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Can only be added once',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.body,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              18.0.height,
              TextInputField(
                header: 'Country of Residence',
                readOnly: true,
                controller: _countryController,
                hint: 'Enter your country of residence',
                inputType: TextInputType.text,
                validator: validateGeneric,
              ),
              4.0.height,
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Contact support to update',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.body,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.surface, width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListenableBuilder(
                listenable: Listenable.merge([
                  _emailController,
                  _referrerCodeController,
                ]),
                builder: (context, _) {
                  final canSave = (referralCodeEditted && !hasUsedReferrerCode) || emailEditted;

                  return MainButton(
                    text: 'Save Changes',
                    isLoading: applyingCode,
                    onPressed: canSave
                        ? () {
                            ref.read(updateProfileProvider.notifier).updateProfile(
                                  referralCode: referralCodeEditted ? _referrerCodeController.text.trim().toUpperCase() : null,
                                  email: emailEditted ? _emailController.text.trim() : null,
                                );
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
    );
  }
}
