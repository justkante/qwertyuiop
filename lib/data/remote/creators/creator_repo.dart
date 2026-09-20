import 'package:creatify_mobile/data/models/requests/rates_card_req.dart' hide Category;
import 'package:creatify_mobile/data/models/requests/report_account_req.dart';
import 'package:creatify_mobile/data/models/requests/resolve_bank_acct_req.dart';
import 'package:creatify_mobile/data/models/requests/save_payout_details_req.dart';
import 'package:creatify_mobile/data/models/requests/update_availability_req.dart';
import 'package:creatify_mobile/data/models/responses/bank_item_dto.dart';
import 'package:creatify_mobile/data/models/responses/creator_availabiity_dto.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/data/models/responses/get_report_reasons_dto.dart';
import 'package:creatify_mobile/data/models/responses/make_subcription_payment_dto.dart';
import 'package:creatify_mobile/data/models/responses/my_subcription_dto.dart';
import 'package:creatify_mobile/data/models/responses/niche_item_dto.dart';
import 'package:creatify_mobile/data/models/responses/onboard_stripe_dto.dart';
import 'package:creatify_mobile/data/models/responses/onboarding_status_dto.dart';
import 'package:creatify_mobile/data/models/responses/payout_details_dto.dart';
import 'package:creatify_mobile/data/models/responses/portfolio_dto.dart';
import 'package:creatify_mobile/data/models/responses/recommended_creators_dto.dart';
import 'package:creatify_mobile/data/models/responses/recruiter_profile_dto.dart' hide Category;
import 'package:creatify_mobile/data/models/responses/referral_stats.dart';
import 'package:creatify_mobile/data/models/responses/referred_user.dart';
import 'package:creatify_mobile/data/models/responses/resolved_bank_acct_dto.dart';
import 'package:creatify_mobile/data/models/responses/stripe_dashboard_dto.dart';
import 'package:creatify_mobile/data/models/responses/subcriptions_plans_dto.dart';
import 'package:creatify_mobile/data/remote/creators/creator_service.dart';

abstract class CreatorRepo {
  Future<OnboardingStatusDto> getOnboardingStatus();
  Future<String> startOnboarding();
  Future<String> uploadProfileImage(String filePath);
  Future<List<NicheItemDto>> getCreatorNiches();
  Future<List<NicheItemDto>> getGroupedCreatorNiches();
  Future<List<BankItemDto>> getBanks();
  Future<List<StatesItemDto>> getStates();
  Future<ResolvedBankAccountDto> resolveBankAccount(ResolveBankAccountReq req);
  Future<String> savePayoutDetails(SavePayoutDetailsReq req);
  Future<PayoutDetailsDto> getPayoutDetails();
  Future<String> saveVirtualRateCard(RatesCardReq req);
  Future<String> skipPortfolioUpload();
  Future<String> uploadPortfolio(Map<String, dynamic> portfolioData);
  Future<PortfolioDto> getPortfolio();
  Future<String> deletePortfolioItem(String id);
  Future<CreatorAvailabilityDto> getCreatorAvailability({required int year, required int month});
  Future<String> updateAvailability(UpdateAvailabilityReq req);
  Future<CreatorProfileDto> getCreatorProfile(String id, {String? timeframe});
  Future<RecruiterProfileDto> getRecruiterProfile(String id, {String? timeframe});
  Future<List<CreatorProfileDto>> filterCreators(
      {String? name, String? priceMin, String? priceMax, String? category, String? location});
  Future<List<CreatorProfileDto>> getFavoriteCreators();
  Future<String> addToFavorites(String id);
  Future<String> removeFromFavorites(String id);
  Future<List<ReportReasonsDto>> getReportReasons();
  Future<List<ReportReasonsDto>> getReportBookingReasons();
  Future<String> reportCreatorAccount(ReportAccountReq req);
  Future<List<SubscriptionsPlanDto>> getSubscriptionPlans();
  Future<MakeSubcriptionPaymentDto> makeSubscriptionPayment(String planId);
  Future<String> verifySubscriptionPayment(String reference);
  Future<String> cancelSubscription(String id);
  Future<String> toggleAutoRenewSubscription({required String id, required bool autoRenew});
  Future<MySubscriptionDto> getMySubscription();
  Future<ReferralStats> getReferralStats();
  Future<String> claimReferralReward();
  Future<String> claimAmbassadorCommission();
  Future<AmbassadorStats> getAmbassadorReferredUsers();
  Future<String> updateProfile({String? referralCode, String? countryCode});
  Future<StripeOnboardDto> stripeOnboardCreator();
  Future<StripeDashboardDto> getStripeDashboardLink();
  Future<RecommendedCreatorsDto> recommendedCreators();
  Future<List<Category>> getPreferences();
  Future<String> updatePreferences(List<String> categoryIds);
}

class CreatorRepoImpl implements CreatorRepo {
  final CreatorService _creatorService;

  CreatorRepoImpl(this._creatorService);

  @override
  Future<List<BankItemDto>> getBanks() async {
    return await _creatorService.getBanks();
  }

  @override
  Future<List<NicheItemDto>> getCreatorNiches() async {
    return await _creatorService.getCreatorNiches();
  }

  @override
  Future<OnboardingStatusDto> getOnboardingStatus() async {
    return await _creatorService.getOnboardingStatus();
  }

  @override
  Future<ResolvedBankAccountDto> resolveBankAccount(ResolveBankAccountReq req) async {
    return await _creatorService.resolveBankAccount(req);
  }

  @override
  Future<String> savePayoutDetails(SavePayoutDetailsReq req) async {
    return await _creatorService.savePayoutDetails(req);
  }

  @override
  Future<String> startOnboarding() async {
    return await _creatorService.startOnboarding();
  }

  @override
  Future<String> deletePortfolioItem(String id) async {
    return await _creatorService.deletePortfolioItem(id);
  }

  @override
  Future<PortfolioDto> getPortfolio() async {
    return await _creatorService.getPortfolio();
  }

  @override
  Future<String> skipPortfolioUpload() async {
    return await _creatorService.skipPortfolioUpload();
  }

  @override
  Future<String> uploadPortfolio(Map<String, dynamic> portfolioData) async {
    return await _creatorService.uploadPortfolio(portfolioData);
  }

  @override
  Future<List<StatesItemDto>> getStates() async {
    return await _creatorService.getStates();
  }

  @override
  Future<String> updateAvailability(UpdateAvailabilityReq req) async {
    return await _creatorService.updateAvailability(req);
  }

  @override
  Future<CreatorAvailabilityDto> getCreatorAvailability(
      {required int year, required int month}) async {
    return await _creatorService.getCreatorAvailability(year: year, month: month);
  }

  @override
  Future<String> addToFavorites(String id) async {
    return await _creatorService.addToFavorites(id);
  }

  @override
  Future<CreatorProfileDto> getCreatorProfile(String id, {String? timeframe}) async {
    return await _creatorService.getCreatorProfile(id, timeframe: timeframe);
  }

  @override
  Future<List<CreatorProfileDto>> getFavoriteCreators() async {
    return await _creatorService.getFavoriteCreators();
  }

  @override
  Future<String> removeFromFavorites(String id) async {
    return await _creatorService.removeFromFavorites(id);
  }

  @override
  Future<List<CreatorProfileDto>> filterCreators({
    String? name,
    String? priceMin,
    String? priceMax,
    String? category,
    String? location,
  }) async {
    return await _creatorService.filterCreators(
      name: name,
      priceMin: priceMin,
      priceMax: priceMax,
      category: category,
      location: location,
    );
  }

  @override
  Future<PayoutDetailsDto> getPayoutDetails() async {
    return await _creatorService.getPayoutDetails();
  }

  @override
  Future<String> reportCreatorAccount(ReportAccountReq req) async {
    return await _creatorService.reportCreatorAccount(req);
  }

  @override
  Future<List<ReportReasonsDto>> getReportReasons() async {
    return await _creatorService.getReportReasons();
  }

  @override
  Future<String> uploadProfileImage(String filePath) async {
    return await _creatorService.uploadProfileImage(filePath);
  }

  @override
  Future<String> cancelSubscription(String id) async {
    return await _creatorService.cancelSubscription(id);
  }

  @override
  Future<List<SubscriptionsPlanDto>> getSubscriptionPlans() async {
    return await _creatorService.getSubscriptionPlans();
  }

  @override
  Future<MakeSubcriptionPaymentDto> makeSubscriptionPayment(String planId) async {
    return await _creatorService.makeSubscriptionPayment(planId);
  }

  @override
  Future<String> toggleAutoRenewSubscription({required String id, required bool autoRenew}) async {
    return await _creatorService.toggleAutoRenewSubscription(id: id, autoRenew: autoRenew);
  }

  @override
  Future<String> verifySubscriptionPayment(String reference) async {
    return await _creatorService.verifySubscriptionPayment(reference);
  }

  @override
  Future<MySubscriptionDto> getMySubscription() async {
    return await _creatorService.getMySubscription();
  }

  @override
  Future<List<ReportReasonsDto>> getReportBookingReasons() async {
    return await _creatorService.getReportBookingReasons();
  }

  @override
  Future<String> saveVirtualRateCard(RatesCardReq req) async {
    return await _creatorService.saveVirtualRateCard(req);
  }

  @override
  Future<RecruiterProfileDto> getRecruiterProfile(String id, {String? timeframe}) async {
    return await _creatorService.getRecruiterProfile(id, timeframe: timeframe);
  }

  @override
  Future<ReferralStats> getReferralStats() async {
    return await _creatorService.getReferralStats();
  }

  @override
  Future<String> claimReferralReward() async {
    return await _creatorService.claimReferralReward();
  }

  @override
  Future<String> updateProfile({String? referralCode, String? countryCode}) async {
    return await _creatorService.updateProfile(referralCode, countryCode);
  }

  @override
  Future<StripeDashboardDto> getStripeDashboardLink() async {
    return await _creatorService.getStripeDashboardLink();
  }

  @override
  Future<StripeOnboardDto> stripeOnboardCreator() async {
    return await _creatorService.stripeOnboardCreator();
  }

  @override
  Future<List<Category>> getPreferences() async {
    return await _creatorService.getPreferences();
  }

  @override
  Future<RecommendedCreatorsDto> recommendedCreators() async {
    return await _creatorService.recommendedCreators();
  }

  @override
  Future<String> updatePreferences(List<String> categoryIds) async {
    return await _creatorService.updatePreferences(categoryIds);
  }

  @override
  Future<List<NicheItemDto>> getGroupedCreatorNiches() async {
    return await _creatorService.getGroupedCreatorNiches();
  }

  @override
  Future<String> claimAmbassadorCommission() async {
    return await _creatorService.claimAmbassadorCommission();
  }

  @override
  Future<AmbassadorStats> getAmbassadorReferredUsers() async {
    return await _creatorService.getAmbassadorReferredUsers();
  }
}
