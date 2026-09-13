import 'package:creatify_mobile/view/modules/authentication/login_view.dart';
import 'package:creatify_mobile/view/modules/authentication/signup_view.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

ValueNotifier<bool> fromLoginSheet = ValueNotifier<bool>(false);

class LoginSheet extends ConsumerStatefulWidget {
  const LoginSheet({
    super.key,
  });

  @override
  ConsumerState<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends ConsumerState<LoginSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        48.0.height,
        Image.asset(
          AppImages.almostTherePng,
          width: 150,
          height: 150,
        ).animate().scale(),
        24.0.height,
        Text(
          "You’re Almost There!",
          style: context.textTheme.displayMedium,
        ).animate().fadeIn(begin: 0, delay: 300.ms).slideY(begin: .1, end: 0),
        8.0.height,
        Text(
          "To book a creator, chat, and make secure payments, you'll need to create an account or log in.",
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(begin: 0, delay: 400.ms).slideY(begin: .1, end: 0),
        25.0.height,
        MainButton(
          text: 'Log In',
          onPressed: () {
            fromLoginSheet.value = true;

            context.pushAndRemoveUntil(const LoginView());
          },
        ).animate().fadeIn(begin: 0, delay: 700.ms).slideY(begin: .1, end: 0),
        12.0.height,
        InkWell(
          onTap: () {
            context.pushAndRemoveUntil(const SignupView());
          },
          child: Text(
            'Create an Account',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ).animate().fadeIn(begin: 0, delay: 800.ms).slideY(begin: .1, end: 0),
        24.0.height,
      ],
    );
  }
}
