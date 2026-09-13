import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';

/// Done button widget that appears above the keyboard
class KeyboardDoneWidget extends StatelessWidget {
  const KeyboardDoneWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.grey800,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: CupertinoButton(
          padding: const EdgeInsets.only(right: 24.0, top: 8.0, bottom: 8.0),
          onPressed: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: const Text(
            "Done",
            style: TextStyle(
              color: CupertinoColors.activeBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
