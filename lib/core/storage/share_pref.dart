import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefManager {
  static late SharedPreferences prefs;

  static set isFirstLaunch(bool isFirstLaunch) => prefs.setBool("isFirstLaunch", isFirstLaunch);
  static bool get isFirstLaunch => prefs.getBool("isFirstLaunch") ?? true;

  static set isLoggedIn(bool isLoggedIn) => prefs.setBool("isLoggedIn", isLoggedIn);
  static bool get isLoggedIn => prefs.getBool("isLoggedIn") ?? false;

  static set email(String email) => prefs.setString("email", email);
  static String get email => prefs.getString("email") ?? '';

  static set userId(String userId) => prefs.setString("userId", userId);
  static String get userId => prefs.getString("userId") ?? '';

  static set hasBiometrics(bool hasBiometrics) => prefs.setBool("hasBiometrics", hasBiometrics);
  static bool get hasBiometrics => prefs.getBool("hasBiometrics") ?? false;

  static set shownBiometricsSheet(bool shownBiometricsSheet) =>
      prefs.setBool("shownBiometricsSheet", shownBiometricsSheet);
  static bool get shownBiometricsSheet => prefs.getBool("shownBiometricsSheet") ?? false;

  static set isNewLogin(bool isNewLogin) => prefs.setBool("isNewLogin", isNewLogin);
  static bool get isNewLogin => prefs.getBool("isNewLogin") ?? false;

  static set balanceVisible(bool balanceVisible) => prefs.setBool("balanceVisible", balanceVisible);
  static bool get balanceVisible => prefs.getBool("balanceVisible") ?? true;

  // Tour / Showcase preferences
  static set hasSeenTourDialog(bool v) => prefs.setBool("hasSeenTourDialog", v);
  static bool get hasSeenTourDialog => prefs.getBool("hasSeenTourDialog") ?? false;

  static set tourAccepted(bool v) => prefs.setBool("tourAccepted", v);
  static bool get tourAccepted => prefs.getBool("tourAccepted") ?? false;

  static void markScreenTourDone(String screenKey) => prefs.setBool("tour_$screenKey", true);
  static bool isScreenTourDone(String screenKey) => prefs.getBool("tour_$screenKey") ?? false;

  static set countryUpdatedAt(String dateTime) => prefs.setString("countryUpdatedAt", dateTime);
  static String get countryUpdatedAt => prefs.getString("countryUpdatedAt") ?? '';

  static void clear() {
    prefs.clear();
  }

  // Clear everything except isFirstLaunch and tour preferences
  static void clearExceptFirstLaunch() {
    final firstLaunch = isFirstLaunch;
    final seenTourDialog = hasSeenTourDialog;
    final acceptedTour = tourAccepted;
    // Preserve screen tour completion states
    final tourKeys = prefs.getKeys().where((k) => k.startsWith('tour_')).toList();
    final tourValues = {for (var k in tourKeys) k: prefs.getBool(k) ?? false};
    prefs.clear();
    isFirstLaunch = firstLaunch;
    hasSeenTourDialog = seenTourDialog;
    tourAccepted = acceptedTour;
    for (var entry in tourValues.entries) {
      prefs.setBool(entry.key, entry.value);
    }
  }

// Init Shared Preference
  static Future<SharedPreferences> init() async {
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }
}
