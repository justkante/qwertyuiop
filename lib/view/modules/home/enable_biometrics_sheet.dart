import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/biometrics/biometrics_controller.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EnableBiometricsSheet extends ConsumerStatefulWidget {
  const EnableBiometricsSheet({
    super.key,
  });

  @override
  ConsumerState<EnableBiometricsSheet> createState() => _LogoutSheetState();
}

class _LogoutSheetState extends ConsumerState<EnableBiometricsSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        24.0.height,
        SvgPicture.asset(
          Theme.of(context).platform == TargetPlatform.iOS ? AppImages.faceId : AppImages.touchId,
          width: 56,
          height: 56,
          colorFilter: AppColors.primary.colorFilterMode(),
        ).animate().scale(),
        24.0.height,
        Text(
          'Enable Biometrics',
          style: context.textTheme.displayMedium,
        ).animate().fadeIn(begin: 0, delay: 300.ms).slideY(begin: .1, end: 0),
        8.0.height,
        Text(
          "Use your device's biometrics to log in quickly and securely. ${!SharedPrefManager.shownBiometricsSheet ? 'You can always disable this in settings.' : ''}",
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(begin: 0, delay: 400.ms).slideY(begin: .1, end: 0),
        25.0.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Enable Biometrics",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.subHeading,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Switch(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.grey300,
              inactiveThumbColor: Colors.white,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              trackOutlineWidth: WidgetStateProperty.all(0.0),
              value: SharedPrefManager.hasBiometrics,
              onChanged: (value) async {
                if (await Biometrics.deviceEnrolledBiometric()) {
                  if (await Biometrics.reqAuthenticate()) {
                    //await storage.saveData(PrefKey.passCode, widget.passcode);
                    SharedPrefManager.hasBiometrics = true;
                  }
                  setState(() {
                    SharedPrefManager.hasBiometrics = value;
                  });
                } else {
                  SharedPrefManager.hasBiometrics = false;
                  if (context.mounted) {
                    ToastDialog.showError('No Biometrics Enrolled on this device', context);
                  }
                }
              },
            )
          ],
        ).animate().fadeIn(begin: 0, delay: 500.ms).slideY(begin: .1, end: 0),
        36.0.height,
        MainButton(
          text: 'Continue',
          onPressed: () {
            context.pop();
          },
        ).animate().fadeIn(begin: 0, delay: 700.ms).slideY(begin: .1, end: 0),
        12.0.height,
      ],
    );
  }
}
