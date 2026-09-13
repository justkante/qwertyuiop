import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MarkCompletedSheet extends StatefulWidget {
  const MarkCompletedSheet({super.key});

  @override
  State<MarkCompletedSheet> createState() => _MarkCompletedSheetState();
}

class _MarkCompletedSheetState extends State<MarkCompletedSheet> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        12.0.height,
        SvgPicture.asset(
          AppImages.markCompleted,
          width: 115,
          height: 80,
        ),
        16.0.height,

        // MARK: Title
        Text(
          'Mark as Completed?',
          style: context.textTheme.headlineSmall?.copyWith(fontSize: 19),
        ),
        6.0.height,
        Text(
          "Are you sure you want to mark this booking as completed? Once confirmed, the creator will be notified, and this deliverable will be closed",
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        32.0.height,

        Row(
          children: [
            Expanded(
              flex: 5,
              child: MainButton(
                color: AppColors.highlightRed50,
                text: 'Back',
                textColor: AppColors.btnText,
                onPressed: () {
                  context.pop(false);
                },
              ),
            ),
            12.0.width,
            Expanded(
              flex: 6,
              child: MainButton(
                text: 'Yes, Mark as Completed',
                onPressed: () {
                  context.pop(true);
                },
              ),
            ),
          ],
        ),
        24.0.height,
      ],
    );
  }
}
