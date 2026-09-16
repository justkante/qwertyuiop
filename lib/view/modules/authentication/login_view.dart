import 'dart:developer';
import 'dart:io';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/storage/secure-storage/secure_storage.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/core/utils/constants.dart';
import 'package:creatify_mobile/data/models/requests/signin_req.dart';
import 'package:creatify_mobile/view/modules/authentication/enter_verification_sheet.dart';
import 'package:creatify_mobile/view/modules/home/enable_biometrics_sheet.dart';
import 'package:creatify_mobile/view/modules/authentication/forgot-password/forgot_password_email_view.dart';
import 'package:creatify_mobile/view/modules/authentication/signup_view.dart';
import 'package:creatify_mobile/view/modules/authentication/vm/apple_sign_in_vm.dart';
import 'package:creatify_mobile/view/modules/authentication/vm/google_sign_in_vm.dart';
import 'package:creatify_mobile/view/modules/authentication/vm/login_vm.dart';
import 'package:creatify_mobile/view/modules/authentication/widgets/or_button.dart';
import 'package:creatify_mobile/view/modules/search-talents/search_talents_view.dart';
import 'package:creatify_mobile/view/modules/tab-bar/tab_bar_view.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/biometrics/biometrics_controller.dart';
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

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isEditing = false;

  void _textControllerListener() {
    setState(() {
      _isEditing = true;
    });
  }

  // Password Stuvs
  bool obscure = true;
  bool rememberMe = true;

  // Handle Login Request
  handleLoginReq(String email, String password) {
    ref.read(loginProvider.notifier).login(
          SignInReq(
            email: email,
            password: password,
          ),
        );
  }

  @override
  void initState() {
    super.initState();
    emailController.text = SharedPrefManager.email;
    emailController.addListener(_textControllerListener);

    // Auto-prompt biometrics if enabled and email matches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptBiometrics();
    });
  }

  Future<void> _checkAndPromptBiometrics() async {
    if (SharedPrefManager.hasBiometrics &&
        emailController.text == SharedPrefManager.email &&
        emailController.text.isNotEmpty) {
      final storage = inject.get<SecureStorageBase>();
      if (await Biometrics.authenticate()) {
        log('In Auto Biometrics Login');
        var password = await storage.readData(PrefKeys.password);
        if (password != null && password.isNotEmpty) {
          handleLoginReq(SharedPrefManager.email, password);
        }
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loggingIn = ref.watch(loginProvider).isLoading;
    final loggingInApple =
        ref.watch(appleAuthProvider).isLoading || ref.watch(appleSignInProvider).isLoading;
    final loggingInGoogle =
        ref.watch(googleAuthProvider).isLoading || ref.watch(googleSignInProvider).isLoading;

    ref.listen(loginProvider, (_, value) {
      if (value is AsyncData) {
        NavigationService.instance.currentState?.popUntil((route) => route.isFirst);

        context.pushAndRemoveUntil(const TabBarSection());

        // Prompt to enable biometrics if rememberMe was selected and not already enabled
        if (SharedPrefManager.isNewLogin) {
          Future.delayed(const Duration(milliseconds: 500), () {
            AppBottomSheet.showBottomSheet(
              context,
              widget: EnableBiometricsSheet(),
            );
          });
        }
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);

        if (value.error.toString().contains('not verified')) {
          AppBottomSheet.showBottomSheet(
            context,
            enableDrag: false,
            isDismissible: false,
            widget: EnterVerificationCodeSheet(
              email: emailController.text,
            ),
          );
        }
      }
    });

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
        NavigationService.instance.currentState?.popUntil((route) => route.isFirst);

        context.pushAndRemoveUntil(const TabBarSection());
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    ref.listen(appleSignInProvider, (_, value) {
      if (value is AsyncData) {
        NavigationService.instance.currentState?.popUntil((route) => route.isFirst);

        context.pushAndRemoveUntil(const TabBarSection());
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: loggingIn || loggingInApple || loggingInGoogle,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: context.canPop,
          title: Text(
            'Sign In',
            style: context.textTheme.displayMedium?.copyWith(fontSize: 19),
          ),
          actions: [
            InkWell(
              onTap: () {
                NavigationService.instance.push(const SearchTalentsView());
              },
              child: Container(
                margin: const EdgeInsets.only(right: 24),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Use as Guest',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.black2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            child: Column(
              children: [
                Image.asset(AppImages.loginCard),
                54.0.height,
                TextInputField(
                  controller: emailController,
                  header: 'Email',
                  hint: 'Enter Email Address',
                  inputType: TextInputType.emailAddress,
                  autoCorrect: false,
                  validator: validateEmail,
                ),
                16.0.height,
                TextInputField(
                  controller: passwordController,
                  autoCorrect: false,
                  header: 'Password',
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
                8.0.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          rememberMe = !rememberMe;
                        });
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value ?? false;
                                });
                              },
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          8.0.width,
                          Text(
                            'Remember Me',
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.subHeading,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => NavigationService.instance.push(const ForgotPasswordEmailView()),
                      child: Text(
                        'Forgot Password?',
                        style: context.textTheme.bodySmall?.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                32.0.height,
                ListenableBuilder(
                  listenable: Listenable.merge([
                    emailController,
                    passwordController,
                  ]),
                  builder: (context, _) {
                    bool isValid = validateRequiredFields([
                      emailController.text,
                      passwordController.text,
                    ]);
                    return MainButton(
                      text: 'Sign In',
                      isLoading: loggingIn,
                      onPressed: isValid || loggingIn
                          ? () {
                              if (Form.of(context).validate()) {
                                ref.read(loginProvider.notifier).login(
                                      SignInReq(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      ),
                                      rememberMe: rememberMe,
                                    );
                              }
                            }
                          : null,
                    );
                  },
                ),
                if (SharedPrefManager.hasBiometrics &&
                    (!_isEditing && (emailController.text == SharedPrefManager.email))) ...[
                  16.0.height,
                  Center(
                    child: InkWell(
                      splashColor: Colors.transparent,
                      radius: 0,
                      onTap: () async {
                        if (SharedPrefManager.email == emailController.text) {
                          final storage = inject.get<SecureStorageBase>();
                          if (await Biometrics.authenticate()) {
                            log('In Biometrics Login');

                            var password = await storage.readData(PrefKeys.password);

                            handleLoginReq(
                              SharedPrefManager.email,
                              password,
                            );
                          }
                        } else {
                          ToastDialog.showError('Please enable Biometrics in Settings', context);
                        }
                      },
                      child: SvgPicture.asset(
                        Theme.of(context).platform == TargetPlatform.iOS
                            ? AppImages.faceId
                            : AppImages.touchId,
                        colorFilter: AppColors.primary.colorFilterMode(),
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
                12.0.height,
                const OrButton(),
                16.0.height,
                Row(
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
                      text: "Don't have an account? ",
                      style: context.textTheme.bodySmall,
                      children: [
                        TextSpan(
                          text: 'Create Account',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.pushAndRemoveUntil(const SignupView());
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
