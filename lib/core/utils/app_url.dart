import 'package:creatify_mobile/core/third-party/environment.dart';
import 'package:creatify_mobile/core/utils/logger.dart';

enum UrlNo { urlOne, urlTwo }

// Initialize the ApiEndpoints instance
// This is a singleton class that provides API endpoints based on the environment
// and can be initialized with a specific environment.
// It defaults to the staging environment if not initialized.
final endpoints = ApiEndpoints.instance;

class ApiEndpoints {
  static final ApiEndpoints _instance = ApiEndpoints._privateConstructor();
  static ApiEndpoints get instance => _instance;
  static Environmentx? _environment;

  ApiEndpoints._privateConstructor() {
    if (_environment == null) {
      logger.info(
        "${"ApiEndpoints----->"} ,Call init to set the environment, environment set to dev by default",
      );
      _environment = Environmentx.staging;
    }
  }

  /// Set Environment
  static void init(Environmentx environment) {
    _environment = environment;
  }

  static const String devURL = "https://staging-api.creatifyapp.com";
  static const String productionURL = "https://api.creatifyapp.com";
  static const String localURL = "http://10.0.2.2:8000";

  static String get baseUrl {
    if (_environment == Environmentx.prod) return productionURL;
    if (_environment == Environmentx.local) return localURL;
    return devURL;
  }

  /// version
  String get version => "v1";

  // Authentication
  String get login => "/api/auth/sign-in";
  String get signUp => "/api/auth/sign-up";
  String get verifyEmail => "/api/auth/verify-email";
  String get resendVerificationCode => "/api/auth/resend-email-verification";
  String get forgotPassword => "/api/auth/forgot-password";
  String get changePasssword => "/api/auth/change-password";
  String get resetPassword => "/api/auth/reset-password";
  String get resendResetPasswordCode => "/api/auth/resend-password-reset-otp";
  String get resetPasswordVerifyCode => "/api/auth/verify-password-reset-otp";
  String get googleSignIn => "/api/auth/google-sign-in";
  String get appleSignIn => "/api/auth/apple-sign-in";
  String get country => "/api/countries";

  String get deleteAccount => "/api/auth/delete-account";

  String get setPresence => "/api/presence";

  // Creators Onboarding / Profile
  String get editProfileImage => "/api/profile/update-image";
  String get getOnboardingStatus => "/api/onboarding/status";
  String get startCreatorOnboarding => "/api/onboarding/start";
  String get getCreatorNiches => "/api/onboarding/categories";
  String get getGroupedCreatorNiches => "/api/onboarding/categories/grouped";
  String get savePayoutDetails => "/api/onboarding/payout";
  String get getPayoutDetails => "/api/onboarding/payout/details";
  String get updateProfile => "/api/profile/update";

  String get categoryServices => "/api/onboarding/categories-services";

  String get getBanks => "/api/onboarding/banks";
  String get resolveBankAccount => "/api/onboarding/banks/resolve";

  String get getStates => "/api/onboarding/states";
  String get getCreatorPortfolio => "/api/onboarding/portfolio";
  String get uploadCreatorPortfolio => "/api/onboarding/portfolio/upload";
  String deleteCreatorPortfolio(String id) => "/api/onboarding/portfolio/$id";
  String get skipPortfolioUpload => "/api/onboarding/portfolio/skip";

  String get getCreatorAvailability => "/api/onboarding/availability";
  String get updateAvailability => "/api/onboarding/availability";

  String getCreatorProfile(String id) => "/api/creators/$id";
  String getRecruiterProfile(String id) => "/api/recruiters/$id";
  String get getCreator => "/api/creators/search";
  String get getFavoriteCreators => "/api/creators/favorites/list";
  String addToFavorites(String id) => "/api/creators/$id/favorite";
  String removeFromFavorites(String id) => "/api/creators/$id/favorite/remove";

  // Jobs
  String get getJobs => "/api/jobs";
  String get createJob => "/api/jobs";
  String get getAppliedJobs => "/api/jobs/applied";
  String get getMyListings => "/api/jobs/my-listings";
  String get getFavoriteJobs => "/api/jobs/favorites/list";
  String applyToJob(String id) => "/api/jobs/$id/apply";
  String toggleJobFavorite(String id) => "/api/jobs/$id/favorite";
  String closeJob(String id) => "/api/jobs/$id/close";
  String deleteJob(String id) => "/api/jobs/$id";
  String getJobApplications(String id) => "/api/jobs/$id/applications";
  String respondToJobApplication(String id) => "/api/jobs/applications/$id/respond";
  String initializeJobApplicationPayment(String id) => "/api/jobs/applications/$id/initialize-payment";

  // Recent Searches
  String get getRecentSearches => "/api/recent-searches";
  String get saveRecentSearch => "/api/recent-searches";
  String deleteRecentSearch(String id) => "/api/recent-searches/$id";
  String get clearRecentSearches => "/api/recent-searches/clear";

  String get getPreferences => "/api/preferences";
  String get updatePreferences => "/api/update-preferences";
  String get getRecommendedCreators => "/api/recommendations/creators";

  // Referrals
  String get claimReferralReward => "/api/referrals/claim";
  String get referralStats => "/api/referrals/my-stats";
  String get claimAmbassadorCommission => "/api/referrals/claim-commissions";
  String get ambassadorStats => "/api/referrals/ambassador-commissions";

  // Report
  String get reportUser => "/api/report";
  String get getReportReasons => "/api/report/reasons";
  String get getReportBookingReasons => "/api/report/booking/reasons";

  // Bookings
  String getCreatorServices(String id) => "/api/bookings/creators/$id/services";
  String getCreatorUnavailability(String id) => "/api/creators/$id/unavailability";

  String get createBooking => "/api/bookings/create";
  String get getReceivedBookings => "/api/bookings/received";
  String get getSentBookings => "/api/bookings/sent";
  String getDeliverablesList(String bookingId) => "/api/bookings/$bookingId/deliverables";
  String getBookingDetails(String id) => "/api/bookings/$id";
  String acceptBooking(String id) => "/api/bookings/$id/accept";
  String renegotiateBooking(String id) => "/api/bookings/$id/renegotiate";
  String recruiterRespondToRenegotiation(String id) => "/api/bookings/$id/respond-renegotiation";
  String cancelBooking(String id) => "/api/bookings/$id/cancel";
  String get getCancelReasons => "/api/bookings/cancellation-reasons";
  String get getRenegotationReasons => "/api/bookings/renegotiation-reasons";
  String requestBookingExtension(String id) => "/api/bookings/$id/request-extension";
  String recruiterRespondToExtension(String id) => "/api/bookings/extensions/$id/respond";
  String requestBookingRevision(String id) => "/api/bookings/$id/request-revision";
  String get reportBooking => '/api/report/booking';
  String updateTimeBasedBookingStatus(String id) => "/api/bookings/$id/status";
  String updateDeliverableBasedBookingStatus(String bookingId, String deliverableId) =>
      "/api/bookings/$bookingId/deliverables/$deliverableId/status";
  String approveTimeMarkCompleted(String id) => "/api/bookings/$id/approve-completion";
  String approveDeliverableMarkCompleted(String bookingId, String deliverableId) =>
      "/api/bookings/$bookingId/deliverables/$deliverableId/respond";
  String submitReview(String bookingId) => "/api/reviews/bookings/$bookingId";
  String get pendingReviews => "/api/reviews/pending";

  String get saveDraftBooking => "/api/bookings/drafts";
  String get getDraftBookings => "/api/bookings/drafts";
  String deleteDraftBooking(String id) => "/api/bookings/drafts/delete/$id";

  // Payments
  String markTimeBasedBookingAsCompleted(String id) => "/api/payments/bookings/$id/complete";
  String markDeliveryBasedBookingAsCompleted(String bookingId, String deliverableId) =>
      "/api/payments/bookings/$bookingId/deliverables/$deliverableId/complete";

  String initializePayment(String bookingId) => "/api/payments/bookings/$bookingId/initialize";
  String verifyPayment(String reference) => "/api/payments/verify/$reference";
  String get getTransactions => "/api/payments/transactions";
  String getTransactionDetails(String id) => "/api/payments/transactions/$id";

  // Stripe
  String get onboardCreatorToStripe => "/api/stripe/connect/onboard";
  String get dashboardLogin => "/api/stripe/connect/dashboard";
  String get refreshOnboarding => "/api/stripe/connect/onboard/refresh";

  // Wallets
  String get getOrCreateWallet => "/api/wallet";
  String get createVirtualAccount => "/api/wallet/virtual-account/create";
  String get createWalletPin => "/api/wallet/pin/create";
  String get changeWalletPin => "/api/wallet/pin/change";
  String get withdrawFromWallet => "/api/wallet/withdraw";
  String get fundWithCard => "/api/wallet/fund-with-card";
  String verifyWalletFunding(String reference) => "/api/wallet/verify-payment/$reference";
  String get changeTransactionPin => "/api/wallet/pin/change";
  String get forgotPin => "/api/wallet/pin/forgot";
  String get verifyPin => "/api/wallet/pin/reset/verify";
  String get resetPin => "/api/wallet/pin/reset";
  String get resendVerifyWalletPin => '/api/wallet/pin/reset/resend';

  // Chats
  String get pusherAuthorisationUrl => "/api/broadcasting/auth";
  String createChat(String id) => "/api/chat/conversations/user/$id";
  String get getConversationList => "/api/chat/conversations";
  String getMessages(String conversationId) => "/api/chat/conversations/$conversationId/messages";
  String sendMessage(String conversationId) => "/api/chat/conversations/$conversationId/messages";
  String editMessage(String messageId) => "/api/chat/messages/$messageId/edit";
  String markMessagesAsRead(String conversationId) =>
      "/api/chat/conversations/$conversationId/read";
  String sendMessageWithAttachment(String conversationId) =>
      "/api/chat/conversations/$conversationId/messages/attachment";

  // Subscription
  String get getSubscriptionPlans => "/api/subscriptions/plans";
  String get getMySubscription => "/api/subscriptions/my-subscription";
  String get makeSubscriptionPayment => "/api/subscriptions/initialize";
  String verifySubscriptionPayment(String reference) => "/api/subscriptions/verify/$reference";
  String cancelSubscription(String id) => "/api/subscriptions/$id/cancel";
  String autoRenewSubscription(String id) => "/api/subscriptions/$id/toggle-auto-renew";

  // Notifications
  String get getNotifications => "/api/notifications";
  String markNotificationAsRead(String id) => "/api/notifications/read/$id";
  String deleteNotification(String id) => "/api/notifications/delete/$id";

  // Refresh Token
  String get refresh => "/$version/auth/refresh";

  // Auth Token
  String get token => "token";
}

enum Environment { dev, prod }
