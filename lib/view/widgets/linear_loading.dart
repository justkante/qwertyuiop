import 'package:flutter/material.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';

class LineLoadingIndicator extends StatelessWidget {
  const LineLoadingIndicator({
    super.key,
    required this.loading,
  });

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return loading
        ? const LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          )
        : const SizedBox.shrink();
  }
}
