import 'package:flutter/material.dart';

class AppBottomSheet {
  static Future<dynamic> showBottomSheet(
    BuildContext context, {
    required Widget widget,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    final res = await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      enableDrag: enableDrag,
      isScrollControlled: true,
      isDismissible: isDismissible,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return Container(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                ),
                child: SafeArea(
                  child: widget,
                ),
              ),
            );
          },
        );
      },
    );

    return res;
  }
}
