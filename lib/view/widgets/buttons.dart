import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MainButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;
  final Color? loadingColor;
  final Color? borderColor;
  final bool? isLoading;
  final double? fontSize, borderRadius;
  final EdgeInsets? padding;
  final Function()? onPressed;
  const MainButton({
    super.key,
    required this.text,
    this.color = AppColors.primary,
    this.loadingColor,
    this.textColor,
    required this.onPressed,
    this.isLoading,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed == null
          ? null
          : () {
              FocusScope.of(context).unfocus();
              onPressed!();
            },
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: onPressed == null ? AppColors.btnInactive : color,
          borderRadius: BorderRadius.circular(borderRadius ?? 48.r),
          border: Border.all(color: borderColor ?? Colors.transparent),
        ),
        child: isLoading ?? false
            ? Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: loadingColor ?? Colors.white,
                  size: 20,
                ),
              )
            : Center(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: fontSize ?? 14,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? Colors.white,
                      ),
                ),
              ),
      ),
    );
  }
}
