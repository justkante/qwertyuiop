import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';

Future<void> platformSpecificDropdown({
  required BuildContext context,
  required List<String> items,
  required String value,
  required Function(String?) onChanged,
  required GlobalKey<State> key,
}) async {
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            height: 250.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: AppColors.kErrorColor),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    CupertinoButton(
                      child: const Text(
                        "Ok",
                        style: TextStyle(color: AppColors.primary),
                      ),
                      onPressed: () {
                        onChanged(value);
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32.0,
                    onSelectedItemChanged: (index) {
                      //onChanged(items[index]);
                      value = items[index];
                    },
                    scrollController: FixedExtentScrollController(
                      initialItem: items.indexOf(value),
                    ),
                    children: items.map((item) => Text(item)).toList(),
                  ),
                ),
              ],
            ),
          );
        });
  } else {
    final RenderBox textFieldRenderBox = key.currentContext!.findRenderObject() as RenderBox;
    final Offset textFieldOffset = textFieldRenderBox.localToGlobal(Offset.zero);

    return await showMenu<String>(
      color: AppColors.kSecondaryColor,
      context: context,
      position: RelativeRect.fromLTRB(
        textFieldOffset.dx + textFieldRenderBox.size.width,
        textFieldOffset.dy + textFieldRenderBox.size.height,
        textFieldOffset.dx,
        textFieldOffset.dy + 2 * textFieldRenderBox.size.height, // bottom
      ),
      items: items.map((option) {
        return PopupMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
    ).then(onChanged);
  }

  // return DropdownButtonFormField<String>(
  //   value: value,
  //   onChanged: onChanged,
  //   items: items.map((String item) {
  //     return DropdownMenuItem<String>(
  //       value: item,
  //       child: Text(item),
  //     );
  //   }).toList(),
  // );
}
