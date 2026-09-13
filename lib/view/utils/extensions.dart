import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// For SizedBox Spacing
extension DoubleExt on double {
  BorderRadius get toBorderRadius => BorderRadius.circular(this);

  /// a spacer widget
  Spacer get space => const Spacer();

  /// convert a double field to SizedBox with its height
  SizedBox get height => SizedBox(height: this);

  /// convert a double field to SizedBox with its widget
  SizedBox get width => SizedBox(width: this);
}

// For Currency Formatting on Double
extension Amount on dynamic {
  /// For Currency Formatting on Double
  String amountWithCurrency(String symbol) {
    const currencySymbols = {
      'ngn': '₦',
      'ghs': 'GH₵',
      'kes': 'KSh',
      'zar': 'R',
      'xof': 'CFA',
      'usd': '\$',
      'cad': 'CA\$',
      'mxn': '\$',
      'brl': 'R\$',
      'gbp': '£',
      'eur': '€',
      'sek': 'kr',
      'nok': 'kr',
      'dkk': 'kr',
      'bgn': 'лв',
      'czk': 'Kč',
      'gip': '£',
      'huf': 'Ft',
      'chf': 'Fr',
      'pln': 'zł',
      'ron': 'lei',
      'aud': 'A\$',
      'nzd': 'NZ\$',
      'sgd': 'S\$',
      'hkd': 'HK\$',
      'jpy': '¥',
      'inr': '₹',
      'idr': 'Rp',
      'myr': 'RM',
      'thb': '฿',
      'aed': 'د.إ',
    };
    final currencySymbol = currencySymbols[symbol.toLowerCase()] ?? '';
    var formatter = NumberFormat.currency(symbol: currencySymbol, decimalDigits: 2);
    return formatter.format(this);
  }
}

extension CurrencyAmount on dynamic {
  String amountInt({
    int minDecimalPlaces = 2,
    int maxDecimalPlaces = 2,
    bool includeCommas = true,
  }) {
    if (this == null) {
      return "0.0";
    } else {
      // Convert the dynamic value to a double
      final doubleValue = (this is String)
          ? double.tryParse(this) ?? 0.0
          : (this is num)
              ? this.toDouble()
              : 0.0;

      // Create a number format
      var formatter = NumberFormat("#,##0");
      if (minDecimalPlaces > 0) {
        formatter.minimumFractionDigits = minDecimalPlaces;
        formatter.maximumFractionDigits = maxDecimalPlaces;
      }

      // Format the double value
      String result = formatter.format(doubleValue);

      // Optionally add commas
      if (includeCommas) {
        return result;
      } else {
        return result.replaceAll(',', '');
      }
    }
  }
}

// For Color on SVG Assets
extension SvgColor on Color {
  /// For Color on SVG Assets
  ColorFilter colorFilterMode() {
    return ColorFilter.mode(this, BlendMode.srcIn);
  }
}

// Extension to Mask the Characters of a Phone Number aside the last 4 digits
extension MaskString on String {
  // Extension to Mask the Characters of a Phone Number aside the last 4 digits
  String mask() {
    if (length <= 4) {
      // Return the original string if it's 4 characters or less
      return this;
    }

    int len = length;
    String lastFour = substring(len - 4);
    String masked = '*' * 5;

    return masked + lastFour;
  }

  String maskEmail() {
    if (!contains('@')) return this; // Not a valid email

    final parts = split('@');
    final localPart = parts[0];
    final domainPart = parts[1];

    if (localPart.length <= 2) {
      return '${localPart[0]}***@$domainPart';
    } else {
      return '${localPart[0]}***${localPart[localPart.length - 1]}@$domainPart';
    }
  }
}

extension ByteFormat on int {
  String formatBytes() {
    if (this <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(this) / log(1024)).floor();
    final size = this / pow(1024, i);
    return "${size.toInt()} ${suffixes[i]}";
  }
}

extension WidgetPadding on Widget {
  Widget widgetPadding({
    double l = 0.0,
    double t = 0.0,
    double r = 0.0,
    double b = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(l, t, r, b),
      child: this,
    );
  }
}

extension DecimalFormatter on dynamic {
  String formatDecimal({bool useCommas = true}) {
    // Return empty string if null
    if (this == null) return '';

    // Convert to double
    double value;
    try {
      value = double.parse(toString());
    } catch (e) {
      return toString();
    }

    // Get whole number and decimal parts
    List<String> parts = value.toString().split('.');
    String wholeNumber = parts[0];
    String decimal = parts.length > 1 ? parts[1] : '';

    // Format the number according to the decimal place rules
    String formattedNumber;

    // Case 1: If whole number is not 0, use 2 decimal places
    if (wholeNumber != '0') {
      formattedNumber = value.toStringAsFixed(2);
    }
    // Case 2: If whole number is 0
    else {
      // If decimal length > 5, use 5 decimal places
      if (decimal.length > 5) {
        formattedNumber = value.toStringAsFixed(5);
      }
      // Otherwise, use the original decimal length
      else {
        formattedNumber = decimal.isEmpty ? '0' : value.toString();
      }
    }

    // Add commas if requested
    if (useCommas) {
      List<String> parts = formattedNumber.split('.');
      parts[0] = _addCommas(parts[0]);
      formattedNumber = parts.join('.');
    }

    return formattedNumber;
  }

  // Helper method to add commas to the whole number part
  String _addCommas(String wholeNumber) {
    final StringBuffer result = StringBuffer();
    final bool isNegative = wholeNumber.startsWith('-');
    String numberToFormat = isNegative ? wholeNumber.substring(1) : wholeNumber;

    for (int i = 0; i < numberToFormat.length; i++) {
      if (i > 0 && (numberToFormat.length - i) % 3 == 0) {
        result.write(',');
      }
      result.write(numberToFormat[i]);
    }

    return isNegative ? '-${result.toString()}' : result.toString();
  }
}

extension TruncateString on String {
  String truncate(int maxLength) {
    if (length <= maxLength) {
      return this;
    } else {
      return "${substring(0, maxLength)}...";
    }
  }
}

extension DateExtension on DateTime {
  String to12HourFormat() {
    final hour = this.hour;
    final minute = this.minute;
    final period = hour >= 12 ? 'PM' : 'AM';

    // Convert 24-hour format to 12-hour format
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    // Add leading zero to minutes if needed
    final displayMinute = minute.toString().padLeft(2, '0');

    return '$displayHour:$displayMinute$period';
  }

  String toFormattedDate() {
    try {
      final datetime = toLocal();
      final day = datetime.day;
      final month = DateFormat('MMM').format(datetime);

      // Add proper ordinal suffix
      final String suffix = _getOrdinalSuffix(day);

      return '$day$suffix $month';
    } catch (e) {
      throw FormatException('Invalid DateTime Format: $this');
    }
  }

  String toFormattedDateWithYear() {
    try {
      final datetime = toLocal();
      final day = datetime.day;
      final month = DateFormat('MMM').format(datetime);
      final year = datetime.year;

      // Add proper ordinal suffix
      final String suffix = _getOrdinalSuffix(day);

      return '$day$suffix $month, $year';
    } catch (e) {
      throw FormatException('Invalid DateTime Format: $this');
    }
  }

  String transactionDate() {
    final format = DateFormat('MMM dd, yyyy');
    final time = DateFormat('hh:mm a');
    return "${format.format(toLocal())} at ${time.format(toLocal())}";
  }

  /// Helper function to get the ordinal suffix for a number
  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }

    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  // Helper function to get date time in this format: 12:00PM, Aug 12, 2025
  String toBookingDateTime() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mma');
    final localDateTime = toLocal();
    final dateString = dateFormat.format(localDateTime);
    final timeString = timeFormat.format(localDateTime);
    return '$timeString, $dateString';
  }

  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1y ago' : '${years}y ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1mo ago' : '${months}mo ago';
    } else if (difference.inDays >= 7) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1w ago' : '${weeks}w ago';
    } else if (difference.inDays >= 1) {
      return difference.inDays == 1 ? '1d ago' : '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return difference.inHours == 1 ? '1h ago' : '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return difference.inMinutes == 1 ? '1m ago' : '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  String timeNoAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1y' : '${years}y';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1mo' : '${months}mo';
    } else if (difference.inDays >= 7) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1w' : '${weeks}w';
    } else if (difference.inDays >= 1) {
      return difference.inDays == 1 ? '1d' : '${difference.inDays}d';
    } else if (difference.inHours >= 1) {
      return difference.inHours == 1 ? '1h' : '${difference.inHours}h';
    } else if (difference.inMinutes >= 1) {
      return difference.inMinutes == 1 ? '1m' : '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  bool isAtSameDateAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  // Extension to change String Date in format "2023-08-12" and String Time in format "23:40:00" to DateTime
  DateTime toDateTimeFromString({
    String timeString = "00:00:00",
  }) {
    try {
      // Construct date string in "yyyy-MM-dd" format
      final dateString =
          "${this.year.toString().padLeft(4, '0')}-${this.month.toString().padLeft(2, '0')}-${this.day.toString().padLeft(2, '0')}";

      final dateParts = dateString.split('-');
      final timeParts = timeString.split(':');

      if (dateParts.length != 3 || timeParts.length < 2) {
        throw const FormatException('Invalid date or time format');
      }

      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      throw FormatException('Error parsing date and time: $e');
    }
  }

  // Extension to add the time component to a DateTime object using a time string in the format "HH:mm:ss"
  DateTime addTimeFromString(String timeString) {
    try {
      final timeParts = timeString.split(':');
      if (timeParts.length < 2) {
        throw const FormatException('Invalid time format');
      }

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      throw FormatException('Error parsing time: $e');
    }
  }
}

extension TimeStringExtension on String {
  // Helper function to get date time from this format: "08:00:00"(24 hour) to this format: 12:00PM
  String toBookingTime() {
    try {
      final timeParts = split(':');
      if (timeParts.length < 2) return this;

      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';

      // Convert 24-hour format to 12-hour format
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      // Add leading zero to minutes if needed
      final displayMinute = minute.toString().padLeft(2, '0');

      return '$displayHour:$displayMinute$period';
    } catch (e) {
      return this; // Return original string if parsing fails
    }
  }
}

extension StringBoldExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    List<String> s = toLowerCase().split(' ');
    String result = '';
    for (var e in s) {
      result += e.replaceRange(0, 1, e[0].toUpperCase());
      result += ' ';
    }
    return result.trim();
  }

  String toBold() {
    // ANSI escape codes for bold
    const String boldStart = '\x1B[1m';
    const String boldEnd = '\x1B[0m';
    return '$boldStart$this$boldEnd';
  }

  String toHtmlBold() {
    return '<b>$this</b>';
  }

  String toMarkdownBold() {
    return '*$this*';
  }
}

extension CapitalizeExtension on String {
  String capitalize() => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
  String get capitalizeFirst => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

extension TimeExtension on TimeOfDay {
  String toFormattedTime() {
    final hour = this.hour;
    final minute = this.minute;
    final period = hour >= 12 ? 'PM' : 'AM';

    // Convert 24-hour format to 12-hour format
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    // Add leading zero to minutes if needed
    final displayMinute = minute.toString().padLeft(2, '0');

    return '$displayHour:$displayMinute $period';
  }

  String to24HourFormat() {
    final hour = this.hour;
    final minute = this.minute;

    // Add leading zero to hours and minutes if needed
    final displayHour = hour.toString().padLeft(2, '0');
    final displayMinute = minute.toString().padLeft(2, '0');

    return '$displayHour:$displayMinute';
  }
}

// Extension to convert time string like "HH:mm:ss" to "HH:mm"
extension TimeFormatting on String {
  String toShortTime() {
    // Assumes format like "HH:mm:ss"
    if (contains(':')) {
      final parts = split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
    }
    return this; // return original if format unexpected
  }
}

extension StringManipulation on String {
  String removeCommas() {
    final cleaned = replaceAll(',', '');
    return cleaned.isEmpty ? "0" : cleaned;
  }

  String removeHyphen() {
    final cleaned = replaceAll('-', ' ');
    return cleaned;
  }

  String removeSpace() {
    final cleaned = replaceAll(' ', '-');
    return cleaned;
  }

  String addUnderscore() {
    final cleaned = replaceAll(' ', '_');
    return cleaned;
  }

  String addUnderscoreLowercase() {
    final cleaned = replaceAll(' ', '_').toLowerCase();
    return cleaned;
  }

  String removeUnderscoreLowercase() {
    final cleaned = replaceAll('_', ' ').toTitleCase();
    return cleaned;
  }

  String removeSlash() {
    final cleaned = replaceAll('/', '-');
    return cleaned;
  }
}

// Extension to know if the file is an audio file
extension MediaFileExtension on String {
  bool isAudioFile() {
    final audioExtensions = ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'];
    final hasAudioExtension = audioExtensions.any((ext) => toLowerCase().endsWith(ext));
    return hasAudioExtension;
  }
}
