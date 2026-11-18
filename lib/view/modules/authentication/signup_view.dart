import 'dart:io';

import 'package:creatify_mobile/data/models/requests/signup_req.dart';
import 'package:creatify_mobile/data/models/responses/countries_dto.dart';
import 'package:creatify_mobile/view/modules/authentication/account_created_sheet.dart';
import 'package:creatify_mobile/view/modules/authentication/get_countries_sheet.dart';
import 'package:creatify_mobile/view/modules/authentication/enter_verification_sheet.dart';
import 'package:creatify_mobile/view/modules/authentication/login_view.dart';
import 'package:creatify_mobile/view/modules/authentication/vm/apple_sign_in_vm.dart';
import 'package:creatify_mobile/view/modules/authentication/vm/google_sign_in_vm.dart';
import 'package:creatify_mobile/view/modules/authentication/vm/signup_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'vm/signup_vm.dart';
import 'vm/apple_sign_in_vm.dart';
import 'vm/google_sign_in_vm.dart';
import 'get_countries_sheet.dart';
import 'enter_verification_sheet.dart';
import 'login_view.dart';

class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();

  CountriesItemDto? selectedCountry;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    countryController.dispose();
    referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signingUp = ref.watch(signUpProvider).isLoading;
    final loggingInApple =
        ref.watch(appleAuthProvider).isLoading || ref.watch(appleSignInProvider).isLoading;
    final loggingInGoogle =
        ref.watch(googleAuthProvider).isLoading || ref.watch(googleSignInProvider).isLoading;

    // Apple And Google Authentications Listeners
    ref.listen(googleAuthProvider, (_, value) {
      if (value is AsyncData) {
        ref.read(googleSignInProvider.notifier).googleSignIn(value.value ?? '');
      }
      if (value is AsyncError) {
        if (!value.error.toString().contains('GoogleSignInException')) {
          ToastDialog.showError(value.error.toString(), context);
        }
      }
    });

    ref.listen(appleAuthProvider, (_, value) {
      if (value is AsyncData) {
        ref.read(appleSignInProvider.notifier).appleSignIn(value.value!);
      }
      if (value is AsyncError) {
        if (!value.error.toString().contains('SignInWithAppleAuthorizationException')) {
          ToastDialog.showError(value.error.toString(), context);
        }
      }
    });

    // Apple And Google Sign In Listeners
    ref.listen(googleSignInProvider, (_, value) {
      if (value is AsyncData) {
        AppBottomSheet.showBottomSheet(
          context,
          isDismissible: false,
          enableDrag: false,
          widget: AccountCreatedSheet(),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    ref.listen(appleSignInProvider, (_, value) {
      if (value is AsyncData) {
        AppBottomSheet.showBottomSheet(
          context,
          isDismissible: false,
          enableDrag: false,
          widget: AccountCreatedSheet(),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    ref.listen(signUpProvider, (_, value) {
      if (value is AsyncData) {
        AppBottomSheet.showBottomSheet(
          context,
          isDismissible: false,
          enableDrag: false,
          widget: EnterVerificationCodeSheet(
            email: value.value?.email ?? '',
          ),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return PopScope(
      canPop: true,
      child: AbsorbPointer(
        absorbing: signingUp,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: context.canPop,
            title: Text(
              'Create Account',
              style: context.textTheme.displayMedium?.copyWith(fontSize: 19),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              child: Column(
                children: [
                  Image.asset(AppImages.signupCard),
                  25.0.height,
                  TextInputField(
                    controller: nameController,
                    header: 'Name',
                    hint: 'Enter Full Name',
                    inputType: TextInputType.text,
                    validator: validateGeneric,
                  ),
                  16.0.height,
                  TextInputField(
                    controller: emailController,
                    header: 'Email',
                    hint: 'Enter Email Address',
                    inputType: TextInputType.emailAddress,
                    validator: validateEmail,
                  ),
                  16.0.height,
                  TextInputField(
                    controller: passwordController,
                    header: 'Password',
                    hint: 'Enter Password',
                    inputType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: validatePassword,
                  ),
                  16.0.height,
                  TextInputField(
                    controller: countryController,
                    header: 'Country of Residence',
                    hint: 'Select Country',
                    inputType: TextInputType.text,
                    readOnly: true,
                    onPressed: () async {
                      final country = await AppBottomSheet.showBottomSheet(
                        context,
                        widget: const GetCountriesSheet(),
                      );
                      if (country != null) {
                        setState(() {
                          selectedCountry = country;
                          countryController.text = "${country.flag} ${country.name}";
                        });
                      }
                    },
                    suffixIcon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.body,
                      size: 18,
                    ),
                    validator: validateGeneric,
                  ),
                  16.0.height,
                  TextInputField(
                    controller: referralCodeController,
                    header: 'Referrer Code (Optional)',
                    hint: 'Enter Referral Code',
                    inputType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    validator: null,
                  ),
                  32.0.height,
                  MainButton(
                    text: 'Sign Up',
                    isLoading: signingUp,
                    width: double.infinity,
                    borderRadius: 30,
                    fontSize: 15,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onPressed: () {
                      ref.read(signUpProvider.notifier).signUp(
                            SignUpReq(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text,
                              countryCode: selectedCountry?.code,
                              referralCode: referralCodeController.text.trim().isNotEmpty
                                  ? referralCodeController.text.trim()
                                  : null,
                            ),
                          );
                    },
                  ),
                  24.0.height,
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.grey300)),
                      16.0.width,
                      Text(
                        'Or Sign Up with',
                        style: context.textTheme.bodySmall?.copyWith(color: AppColors.body),
                      ),
                      16.0.width,
                      const Expanded(child: Divider(color: AppColors.grey300)),
                    ],
                  ),
                  24.0.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (Platform.isIOS) ...[
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              ref.read(appleAuthProvider.notifier).appleAuth();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.grey100,
                                borderRadius: BorderRadius.circular(48),
                              ),
                              child: loggingInApple
                                  ? Center(
                                      child: LoadingAnimationWidget.staggeredDotsWave(
                                        color: AppColors.black2,
                                        size: 20,
                                      ),
                                    )
                                  : SvgPicture.asset(AppImages.apple, height: 20),
                            ),
                          ),
                        ),
                        16.0.width,
                      ],
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            ref.read(googleAuthProvider.notifier).googleAuth();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.circular(48),
                            ),
                            child: loggingInGoogle
                                ? Center(
                                    child: LoadingAnimationWidget.staggeredDotsWave(
                                      color: AppColors.black2,
                                      size: 20,
                                    ),
                                  )
                                : SvgPicture.asset(AppImages.google, height: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  32.0.height,
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: context.textTheme.bodySmall,
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.pushAndRemoveUntil(const LoginView());
                              },
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.highlightCoral,
                                ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  48.0.height,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
