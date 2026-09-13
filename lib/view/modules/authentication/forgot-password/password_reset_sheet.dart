import 'package:creatify_mobile/view/modules/authentication/login_view.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';

class PasswordResetSheet extends StatefulWidget {
  const PasswordResetSheet({
    super.key,
  });

  @override
  State<PasswordResetSheet> createState() => _PasswordResetSheetState();
}

class _PasswordResetSheetState extends State<PasswordResetSheet> {
  final TextEditingController codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        32.0.height,
        SvgPicture.asset(AppImages.passwordProtected),
        24.0.height,
        Text(
          'Password Reset Successfully!',
          style: context.textTheme.displayMedium,
        ).animate().fadeIn(begin: 0, delay: 300.ms).slideY(begin: .1, end: 0),
        8.0.height,
        Text(
          "Your new password is set. You can now sign in and continue using Creatify with full access",
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(begin: 0, delay: 400.ms).slideY(begin: .1, end: 0),
        25.0.height,
        MainButton(
          text: 'Sign In',
          onPressed: () {
            context.pop();
            context.pushAndRemoveUntil(const LoginView());
          },
        ).animate().fadeIn(begin: 0, delay: 700.ms).slideY(begin: .1, end: 0),
        40.0.height,
      ],
    );
  }
}
