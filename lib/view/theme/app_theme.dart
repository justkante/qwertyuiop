import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

ThemeData themeData() {
  return ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: AppColors.kScaffoldColor,
    fontFamily: FontFamily.geist,
    appBarTheme: appBarTheme(),
    textTheme: textTheme(),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    inputDecorationTheme: inputDecorationTheme(),
    scrollbarTheme: ScrollbarThemeData(
      crossAxisMargin: -5,
      thumbColor: WidgetStateProperty.all(AppColors.primary),
      radius: const Radius.circular(4),
    ),
    radioTheme: const RadioThemeData(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    ),
    checkboxTheme: CheckboxThemeData(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      visualDensity: VisualDensity.compact,
      side: const BorderSide(color: AppColors.kHintColor),
      fillColor: WidgetStateProperty.all(Colors.white),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: AppColors.grey100,
      dialHandColor: AppColors.primary,
      dialBackgroundColor: AppColors.grey300,
      dayPeriodColor: AppColors.grey300,
      hourMinuteColor: AppColors.grey300,
      dayPeriodTextColor: AppColors.body,
      hourMinuteTextColor: AppColors.body,
      cancelButtonStyle: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(AppColors.kErrorColor),
      ),
      confirmButtonStyle: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(AppColors.primary),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    ),
  );
}

InputDecorationTheme inputDecorationTheme() {
  OutlineInputBorder focusInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: AppColors.highlightBlue, width: 1),
  );
  OutlineInputBorder defaultInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: AppColors.grey300, width: 1),
  );
  OutlineInputBorder errorInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: AppColors.kSecondaryColor, width: 1),
  );
  return InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    enabledBorder: defaultInputBorder,
    focusedBorder: focusInputBorder,
    errorBorder: errorInputBorder,
    border: defaultInputBorder,
    fillColor: Colors.white,
    filled: true,
    suffixIconColor: AppColors.kSecondaryColor,
  );
}

PinTheme defaultPinInputTheme = PinTheme(
  width: 50.w,
  height: 55.h,
  textStyle: textTheme.call().displayMedium,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8.r),
    color: Colors.transparent,
    border: Border.all(color: AppColors.grey400),
  ),
);

PinTheme focusedPinInputTheme = PinTheme(
  width: 50.w,
  height: 55.h,
  textStyle: textTheme.call().displayMedium,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8.r),
    color: Colors.transparent,
    border: Border.all(color: AppColors.highlightBlue),
  ),
);

TextTheme textTheme() {
  return const TextTheme(
    displayLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      fontFamily: FontFamily.geist,
      letterSpacing: -0.2,
      color: AppColors.heading,
    ),
    displayMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      fontFamily: FontFamily.geist,
      letterSpacing: -0.4,
      color: AppColors.heading,
    ),
    displaySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontFamily: FontFamily.geist,
      letterSpacing: 0,
      color: AppColors.heading,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.3,
      color: AppColors.body,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.3,
      color: AppColors.body,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.3,
      color: AppColors.body,
    ),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: AppColors.kScaffoldColor,
  );
}

class FontFamily {
  FontFamily._();

  /// Font family: Geist
  static const String geist = 'Geist';

  /// Font family: Inter
  static const String inter = 'Inter';
}
