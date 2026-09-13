import 'dart:ui';

import 'package:flutter/material.dart';

class AppDialog {
  static Future<dynamic> showAppDialog(
    BuildContext context, {
    required Widget widget,
    bool barrierDismissible = true,
    bool removeInsetPadding = false,
  }) async {
    final res = await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: BackdropFilter(
          blendMode: BlendMode.srcIn,
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: double.infinity,
            padding: removeInsetPadding ? EdgeInsets.zero : const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: widget,
          ),
        ),
      ),
    );

    return res;
  }
}
