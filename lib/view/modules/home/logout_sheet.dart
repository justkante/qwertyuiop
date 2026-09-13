import 'package:creatify_mobile/view/modules/authentication/login_view.dart';
import 'package:creatify_mobile/view/modules/home/vm/log_out_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LogoutSheet extends ConsumerStatefulWidget {
  const LogoutSheet({
    super.key,
  });

  @override
  ConsumerState<LogoutSheet> createState() => _LogoutSheetState();
}

class _LogoutSheetState extends ConsumerState<LogoutSheet> {
  @override
  Widget build(BuildContext context) {
    final logoutLoading = ref.watch(logOutProvider).isLoading;

    ref.listen(logOutProvider, (_, value) {
      if (value is AsyncData) {
        context.pushAndRemoveUntil(const LoginView());
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        48.0.height,
        SvgPicture.asset(AppImages.padlock).animate().scale(),
        24.0.height,
        Text(
          'Logout?',
          style: context.textTheme.displayMedium,
        ).animate().fadeIn(begin: 0, delay: 300.ms).slideY(begin: .1, end: 0),
        8.0.height,
        Text(
          "Are you sure you want to log out of Creatify? You'll need to sign in again to access your account",
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(begin: 0, delay: 400.ms).slideY(begin: .1, end: 0),
        25.0.height,
        MainButton(
          text: 'Yes, Logout',
          isLoading: logoutLoading,
          color: AppColors.highlightRed,
          onPressed: () {
            ref.read(logOutProvider.notifier).logOut();
          },
        ).animate().fadeIn(begin: 0, delay: 700.ms).slideY(begin: .1, end: 0),
        40.0.height,
      ],
    );
  }
}
