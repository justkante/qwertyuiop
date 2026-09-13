import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class InitialAvatar extends StatefulWidget {
  final String initials;
  final Color? backgroundColor;
  final double? size;
  final EdgeInsets? padding, margin;
  const InitialAvatar({
    super.key,
    required this.initials,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.size,
  });

  @override
  State<InitialAvatar> createState() => _InitialAvatarState();
}

class _InitialAvatarState extends State<InitialAvatar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.only(left: 6),
      padding: widget.padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        widget.initials,
        style: context.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: widget.size ?? 14,
        ),
      ),
    );
  }
}
