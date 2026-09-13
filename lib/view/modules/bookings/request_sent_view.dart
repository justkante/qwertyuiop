import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RequestSentView extends ConsumerStatefulWidget {
  final String? creatorName;
  const RequestSentView({super.key, this.creatorName});

  @override
  ConsumerState<RequestSentView> createState() => _RequestSentViewState();
}

class _RequestSentViewState extends ConsumerState<RequestSentView> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(AppImages.paperPlane),
            24.0.height,
            Text(
              'Your Request Has been Sent!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.subHeading,
                  ),
            ),
            12.0.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Your booking request has been sent to ${widget.creatorName}. You will be notified once they respond.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.body,
                    ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MainButton(
                text: 'Continue',
                onPressed: () {
                  context.popToFirst();

                  ref.read(navBarController.notifier).index = 2;
                },
              ),
              80.0.height,
            ],
          ),
        ),
      ),
    );
  }
}
