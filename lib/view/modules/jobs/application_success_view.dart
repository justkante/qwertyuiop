import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ApplicationSuccessView extends StatelessWidget {
  final String? recruiterName;
  const ApplicationSuccessView({super.key, this.recruiterName});

  @override
  Widget build(BuildContext context) {
    final displayName = recruiterName?.isNotEmpty == true ? recruiterName : 'the recruiter';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ),
            const Spacer(),
            SvgPicture.asset(AppImages.paperPlane, height: 120),
            24.0.height,
            Text(
              'Your Application Has been Sent',
              style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            12.0.height,
            Text(
              "We've sent your booking request to $displayName. You'll be notified once they respond.",
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            MainButton(
              text: 'Back to Jobs',
              onPressed: () => Navigator.pop(context),
            ),
            24.0.height,
          ],
        ),
      ),
    );
  }
}
