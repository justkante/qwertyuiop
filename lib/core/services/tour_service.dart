import 'package:creatify_mobile/core/storage/share_pref.dart';

/// Manages the guided-tour state across the application.
class TourService {
  TourService._();

  /// Whether the initial tour dialog has ever been presented.
  static bool get hasSeenDialog => SharedPrefManager.hasSeenTourDialog;

  /// Whether the user accepted the tour (as opposed to skipping).
  static bool get tourAccepted => SharedPrefManager.tourAccepted;

  /// Returns `true` when the tour for [screenKey] should be shown:
  /// the user accepted the tour and hasn't completed this screen yet.
  static bool shouldShowScreenTour(String screenKey) {
    return tourAccepted && !SharedPrefManager.isScreenTourDone(screenKey);
  }

  /// Mark the tour for [screenKey] as finished.
  static void markScreenDone(String screenKey) {
    SharedPrefManager.markScreenTourDone(screenKey);
  }

  // ── Screen key constants ──
  static const String mainTabs = 'main_tabs';
  static const String homeTab = 'home_tab';
  static const String searchTab = 'search_tab';
  static const String walletTab = 'wallet_tab';
  static const String myCreatorProfile = 'my_creator_profile';
  static const String creatorProfile = 'creator_profile';
  static const String bookCreator = 'book_creator';
  static const String bookingDetails = 'booking_details';
  static const String chatConversation = 'chat_conversation';
  static const String deliverables = 'deliverables';
  static const String wallet = 'wallet';
  static const String notifications = 'notifications';
  static const String onboarding = 'onboarding';
}
