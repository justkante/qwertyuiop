import 'package:creatify_mobile/view/modules/authentication/select_user_type_view.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';

class AccountCreatedSheet extends StatefulWidget {
  const AccountCreatedSheet({
    super.key,
  });

  @override
  State<AccountCreatedSheet> createState() => _AccountCreatedSheetState();
}

class _AccountCreatedSheetState extends State<AccountCreatedSheet> {
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
        SvgPicture.asset(AppImages.confetti).animate().scale(delay: 100.ms),
        24.0.height,
        Text(
          'Account Created Successfully!',
          style: context.textTheme.displayMedium,
        ).animate().fadeIn(begin: 0, delay: 300.ms).slideY(begin: .1, end: 0),
        8.0.height,
        Text(
          "Welcome aboard! Your Creatify account is ready. Let's get you started on your journey",
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(begin: 0, delay: 400.ms).slideY(begin: .1, end: 0),
        25.0.height,
        MainButton(
          text: 'Continue',
          onPressed: () {
            context.pop();
            context.push(const SelectUserTypeView());
          },
        ).animate().fadeIn(begin: 0, delay: 700.ms).slideY(begin: .1, end: 0),
        40.0.height,
      ],
    );
  }
}
