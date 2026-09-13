import 'package:creatify_mobile/view/modules/authentication/signup_view.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';

class AccountNotFoundSheet extends StatefulWidget {
  const AccountNotFoundSheet({
    super.key,
  });

  @override
  State<AccountNotFoundSheet> createState() => _AccountNotFoundSheetState();
}

class _AccountNotFoundSheetState extends State<AccountNotFoundSheet> {
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
        48.0.height,
        SvgPicture.asset(AppImages.notFound).animate().scale(),
        24.0.height,
        Text(
          'Account Not Found',
          style: context.textTheme.displayMedium,
        ).animate().fadeIn(begin: 0, delay: 300.ms).slideY(begin: .1, end: 0),
        8.0.height,
        Text(
          "We couldn't find an account with this email. Double-check your entry or create a new account to get started",
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(begin: 0, delay: 400.ms).slideY(begin: .1, end: 0),
        25.0.height,
        MainButton(
          text: 'Create Account',
          onPressed: () {
            context.pop();
            context.push(const SignupView());
          },
        ).animate().fadeIn(begin: 0, delay: 700.ms).slideY(begin: .1, end: 0),
        40.0.height,
      ],
    );
  }
}
