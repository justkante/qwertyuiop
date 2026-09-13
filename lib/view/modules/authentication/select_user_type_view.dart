import 'package:creatify_mobile/data/remote/auth/push_notifications_impl.dart';
import 'package:creatify_mobile/view/modules/tab-bar/tab_bar_view.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SelectUserTypeView extends ConsumerStatefulWidget {
  const SelectUserTypeView({super.key});

  @override
  ConsumerState<SelectUserTypeView> createState() => _SelectUserTypeViewState();
}

class _SelectUserTypeViewState extends ConsumerState<SelectUserTypeView> {
  final TextEditingController _userTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(oneSignalpushNotificationProvider).init();
    });
  }

  @override
  void dispose() {
    _userTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select User Type',
              style: context.textTheme.displayLarge,
            ),
            8.0.height,
            Text(
              "Tell us how you'd like to use Creatify. Don't worry, you can switch roles anytime",
              style: context.textTheme.bodySmall,
            ),
            42.0.height,

            // Creator
            InkWell(
              onTap: () {
                setState(() {
                  _userTypeController.text = 'creator';
                });
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 34, 16, 0),
                decoration: BoxDecoration(
                  color: AppColors.highlightBlue,
                  borderRadius: BorderRadius.circular(16),
                  border: _userTypeController.text == 'creator'
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Creator',
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          4.0.height,
                          Text(
                            "Showcase your talent, set your rates, and get booked",
                            style: context.textTheme.bodySmall?.copyWith(color: AppColors.grey300),
                          ),
                          24.0.height,
                        ],
                      ),
                    ),
                    8.0.width,
                    SvgPicture.asset(AppImages.creator)
                  ],
                ),
              ),
            ),
            16.0.height,

            // Recruiter
            InkWell(
              onTap: () {
                setState(() {
                  _userTypeController.text = 'recruiter';
                });
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 34, 16, 0),
                decoration: BoxDecoration(
                  color: AppColors.highlightYellow,
                  borderRadius: BorderRadius.circular(16),
                  border: _userTypeController.text == 'recruiter'
                      ? Border.all(color: AppColors.highlightCoral, width: 2)
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recruiter',
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          4.0.height,
                          Text(
                            "Discover talent, manage bookings, and bring your ideas to life",
                            style: context.textTheme.bodySmall?.copyWith(color: AppColors.grey300),
                          ),
                          24.0.height,
                        ],
                      ),
                    ),
                    8.0.width,
                    SvgPicture.asset(AppImages.recruiter)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MainButton(
              text: 'Continue',
              onPressed: _userTypeController.text.isNotEmpty
                  ? () {
                      NavigationService.instance.currentState?.popUntil((route) => route.isFirst);

                      context.pushAndRemoveUntil(
                        TabBarSection(
                          showOnboardingSheet: _userTypeController.text == 'creator' ? true : false,
                        ),
                      );
                    }
                  : null,
            ),
            12.0.height,
          ],
        ),
      ),
    );
  }
}
