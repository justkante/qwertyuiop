import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeleteAccountConfirmation extends ConsumerStatefulWidget {
  const DeleteAccountConfirmation({
    super.key,
  });

  @override
  ConsumerState<DeleteAccountConfirmation> createState() => _LogoutSheetState();
}

class _LogoutSheetState extends ConsumerState<DeleteAccountConfirmation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        8.0.height,
        Center(
          child: Text(
            '!',
            textAlign: TextAlign.center,
            style: context.textTheme.displayLarge?.copyWith(
              fontSize: 70,
              color: AppColors.highlightRed,
            ),
          ),
        ).animate().scale(),
        24.0.height,
        Text(
          'Are you absolutely sure?',
          style: context.textTheme.displayMedium,
        ).animate().fadeIn(begin: 0, delay: 300.ms).slideY(begin: .1, end: 0),
        8.0.height,
        Text(
          "Deleting your account will permanently remove your profile and all associated data. This action cannot be undone.",
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
                  context.pop(true);
                },
              ).animate().fadeIn(begin: 0, delay: 700.ms).slideY(begin: .1, end: 0),
            ),
            12.0.width,
            Expanded(
              child: MainButton(
                text: 'No, Cancel',
                textColor: AppColors.black2,
                color: AppColors.grey400,
                onPressed: () {
                  context.pop(false);
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
