import 'package:flutter/material.dart';

/// Extension on BuildContext to provide easy access to theme properties
extension ThemeExtensions on BuildContext {
  /// Get the current TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get the current ColorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get the current ThemeData
  ThemeData get theme => Theme.of(this);

  /// Additional commonly used theme properties

  /// Get primary color
  Color get primaryColor => Theme.of(this).primaryColor;

  /// Get scaffold background color
  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;

  /// Get app bar theme
  AppBarThemeData get appBarTheme => Theme.of(this).appBarTheme;

  /// Get input decoration theme
  InputDecorationThemeData get inputDecorationTheme => Theme.of(this).inputDecorationTheme;
}
