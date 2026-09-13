import 'package:flutter/material.dart';

/// Centralized GlobalKeys for all guided-tour showcase targets.
class TourKeys {
  TourKeys._();

  // ── Bottom Navigation Tabs ──
  static final navHome = GlobalKey(debugLabel: 'tour_navHome');
  static final navSearch = GlobalKey(debugLabel: 'tour_navSearch');
  static final navBookings = GlobalKey(debugLabel: 'tour_navBookings');
  static final navMessages = GlobalKey(debugLabel: 'tour_navMessages');
  static final navWallet = GlobalKey(debugLabel: 'tour_navWallet');

  // ── Home Screen ──
  static final homeDrawerMenu = GlobalKey(debugLabel: 'tour_homeDrawerMenu');
  static final homeCreatorCard = GlobalKey(debugLabel: 'tour_homeCreatorCard');
  static final homeSearchTalentCard = GlobalKey(debugLabel: 'tour_homeSearchTalentCard');

  // ── Search / Filter Talents ──
  static final discoverScreen = GlobalKey(debugLabel: 'tour_discoverScreen');
  static final searchSearchBar = GlobalKey(debugLabel: 'tour_searchSearchBar');
  static final searchFilterIcon = GlobalKey(debugLabel: 'tour_searchFilterIcon');

  // ── My Creator Profile ──
  static final myCreatorMenu = GlobalKey(debugLabel: 'tour_myCreatorMenu');

  // ── Creator Profile View ──
  static final creatorPortfolio = GlobalKey(debugLabel: 'tour_creatorPortfolio');
  static final creatorServicesPricing = GlobalKey(debugLabel: 'tour_creatorServicesPricing');
  static final creatorReviews = GlobalKey(debugLabel: 'tour_creatorReviews');
  static final creatorBookButton = GlobalKey(debugLabel: 'tour_creatorBookButton');

  // ── Book Creator Screen ──
  static final bookingTypeSelector = GlobalKey(debugLabel: 'tour_bookingTypeSelector');
  static final bookingFormDescription = GlobalKey(debugLabel: 'tour_bookingFormDescription');
  static final bookingFormDetails = GlobalKey(debugLabel: 'tour_bookingFormDetails');

  // ── Booking Details Screen ──
  static final bookingAcceptNegotiate = GlobalKey(debugLabel: 'tour_bookingAcceptNegotiate');
  static final bookingEscrow = GlobalKey(debugLabel: 'tour_bookingEscrow');
  static final bookingCancel = GlobalKey(debugLabel: 'tour_bookingCancel');

  // ── Chat Conversation Screen ──
  static final chatInput = GlobalKey(debugLabel: 'tour_chatInput');
  static final chatActionButtons = GlobalKey(debugLabel: 'tour_chatActionButtons');

  // ── Deliverables Screen ──
  static final deliverablesList = GlobalKey(debugLabel: 'tour_deliverablesList');

  // ── Wallet / Transactions ──
  static final walletBalance = GlobalKey(debugLabel: 'tour_walletBalance');
  static final walletPayout = GlobalKey(debugLabel: 'tour_walletPayout');

  // ── Notifications ──
  static final notificationsAlerts = GlobalKey(debugLabel: 'tour_notificationsAlerts');

  // ── Profile / Onboarding Sheet ──
  static final onboardingBio = GlobalKey(debugLabel: 'tour_onboardingBio');
  static final onboardingVerification = GlobalKey(debugLabel: 'tour_onboardingVerification');
}
