import 'package:creatify_mobile/core/utils/app_func_utils.dart';
import 'package:creatify_mobile/view/modules/home/delete_account_view.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeleteAccountSheet extends ConsumerStatefulWidget {
  const DeleteAccountSheet({
    super.key,
  });

  @override
  ConsumerState<DeleteAccountSheet> createState() => _LogoutSheetState();
}

class _LogoutSheetState extends ConsumerState<DeleteAccountSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        8.0.height,
        Center(
          child: Text(
            '🥲',
            textAlign: TextAlign.center,
            style: context.textTheme.displayLarge?.copyWith(fontSize: 70),
          ),
        ).animate().scale(),
        24.0.height,
        Text(
          'Leaving us?',
          style: context.textTheme.displayMedium,
        ).animate().fadeIn(begin: 0, delay: 300.ms).slideY(begin: .1, end: 0),
        8.0.height,
        Text(
          "Are you sure you want to delete your account? Your account and all associated data will be permanently removed. This can’t be reversed.",
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(begin: 0, delay: 400.ms).slideY(begin: .1, end: 0),
        25.0.height,
        Row(
          children: [
            Expanded(
              child: MainButton(
                text: 'Yes, Delete',
                color: AppColors.highlightRed,
                onPressed: () {
                  context.pop();
                  NavigationService.instance.push(const DeleteAccountView());
                },
              ).animate().fadeIn(begin: 0, delay: 700.ms).slideY(begin: .1, end: 0),
            ),
            12.0.width,
            Expanded(
              child: MainButton(
                text: 'No, Contact Support',
                textColor: AppColors.black2,
                color: AppColors.grey400,
                onPressed: () {
                  AppUtils.openLink(SocialPlatform.email);
                },
              ).animate().fadeIn(begin: 0, delay: 700.ms).slideY(begin: .1, end: 0),
            ),
          ],
        ),
        40.0.height,
      ],
    );
  }
}
