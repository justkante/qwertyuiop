import 'package:creatify_mobile/core/error/api_exception.dart';
import 'package:creatify_mobile/core/error/stripe_onboarding_exception.dart';
import 'package:creatify_mobile/core/http/http_service.dart';
import 'package:creatify_mobile/core/utils/app_url.dart';
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
import 'package:creatify_mobile/data/models/responses/stripe_onboarding_data_dto.dart';
import 'package:creatify_mobile/data/models/responses/subcriptions_plans_dto.dart';
import 'package:dio/dio.dart';

class CreatorService {
  final HttpService _networkService;

  CreatorService({required HttpService networkService}) : _networkService = networkService;

  Future<OnboardingStatusDto> getOnboardingStatus() async {
    try {
      final response = await _networkService.request(
        endpoints.getOnboardingStatus,
        RequestMethod.get,
      );

      return OnboardingStatusDto.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> startOnboarding() async {
    try {
      final response = await _networkService.request(
        endpoints.startCreatorOnboarding,
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<NicheItemDto>> getCreatorNiches() async {
    try {
      final response = await _networkService.request(
        endpoints.getCreatorNiches,
        RequestMethod.get,
        enableCache: true,
      );

      return List<NicheItemDto>.from(
        response.data['data'].map((x) => NicheItemDto.fromJson(x)),
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<NicheItemDto>> getGroupedCreatorNiches() async {
    try {
      final response = await _networkService.request(
        endpoints.getGroupedCreatorNiches,
        RequestMethod.get,
        enableCache: true,
      );

      return List<NicheItemDto>.from(
        response.data['data'].map((x) => NicheItemDto.fromJson(x)),
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> uploadProfileImage(String filePath) async {
    try {
      final response = await _networkService.request(
        endpoints.editProfileImage,
        RequestMethod.post,
        data: FormData.fromMap({
          'profile_image': await MultipartFile.fromFile(filePath),
        }),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<BankItemDto>> getBanks() async {
    try {
      final response = await _networkService.request(
        endpoints.getBanks,
        RequestMethod.get,
        enableCache: true,
      );

      return List<BankItemDto>.from(
        response.data['data'].map((x) => BankItemDto.fromJson(x)),
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<StatesItemDto>> getStates() async {
    try {
      final response = await _networkService.request(
        endpoints.getStates,
        RequestMethod.get,
        enableCache: true,
      );

      return List<StatesItemDto>.from(
        response.data['data'].map((x) => StatesItemDto.fromJson(x)),
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<ResolvedBankAccountDto> resolveBankAccount(ResolveBankAccountReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.resolveBankAccount,
        RequestMethod.post,
        data: req.toJson(),
      );

      return ResolvedBankAccountDto.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> savePayoutDetails(SavePayoutDetailsReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.savePayoutDetails,
        RequestMethod.post,
        data: req.toJson(),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<PayoutDetailsDto> getPayoutDetails() async {
    try {
      final response = await _networkService.request(
        endpoints.getPayoutDetails,
        RequestMethod.get,
      );

      return PayoutDetailsDto.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> saveVirtualRateCard(RatesCardReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.categoryServices,
        RequestMethod.post,
        data: req.toJson(),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> skipPortfolioUpload() async {
    try {
      final response = await _networkService.request(
        endpoints.skipPortfolioUpload,
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> uploadPortfolio(Map<String, dynamic> portfolioData) async {
    try {
      final response = await _networkService.request(
        endpoints.uploadCreatorPortfolio,
        RequestMethod.post,
        data: FormData.fromMap(portfolioData),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<PortfolioDto> getPortfolio() async {
    try {
      final response = await _networkService.request(
        endpoints.getCreatorPortfolio,
        RequestMethod.get,
      );

      return PortfolioDto.fromJson(response.data);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> deletePortfolioItem(String id) async {
    try {
      final response = await _networkService.request(
        endpoints.deleteCreatorPortfolio(id),
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<CreatorAvailabilityDto> getCreatorAvailability({
    required int year,
    required int month,
  }) async {
    try {
      final response = await _networkService.request(
        "${endpoints.getCreatorAvailability}?year=$year&month=$month",
        RequestMethod.get,
      );

      return CreatorAvailabilityDto.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> updateAvailability(UpdateAvailabilityReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.updateAvailability,
        RequestMethod.post,
        data: req.toJson(),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<CreatorProfileDto> getCreatorProfile(String id) async {
    try {
      final response = await _networkService.request(
        endpoints.getCreatorProfile(id),
        RequestMethod.get,
      );

      return CreatorProfileDto.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<RecruiterProfileDto> getRecruiterProfile(String id) async {
    try {
      final response = await _networkService.request(
        endpoints.getRecruiterProfile(id),
        RequestMethod.get,
      );

      return RecruiterProfileDto.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<CreatorProfileDto>> filterCreators({
    String? name,
    String? priceMin,
    String? priceMax,
    String? category,
    String? location,
  }) async {
    try {
      final String queries = {
        if (name != null && name.isNotEmpty) 'q': name,
        if (priceMin != null && priceMin.isNotEmpty) 'price_min': priceMin,
        if (priceMax != null && priceMax.isNotEmpty) 'price_max': priceMax,
        if (category != null && category.isNotEmpty) 'categories': category,
        if (location != null && location.isNotEmpty) 'state_id': location,
      }
          .entries
          .map((e) => "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}")
          .join('&');

      final response = await _networkService.request(
        "${endpoints.getCreator}?$queries",
        RequestMethod.get,
      );

      return List<CreatorProfileDto>.from(
        response.data['data'].map((x) => CreatorProfileDto.fromJson(x)),
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<RecommendedCreatorsDto> recommendedCreators() async {
    try {
      final response = await _networkService.request(
        endpoints.getRecommendedCreators,
        RequestMethod.get,
      );

      return RecommendedCreatorsDto.fromJson(response.data);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<CreatorProfileDto>> getFavoriteCreators() async {
    try {
      final response = await _networkService.request(
        endpoints.getFavoriteCreators,
        RequestMethod.get,
      );

      return List<CreatorProfileDto>.from(
        response.data['data'].map((x) => CreatorProfileDto.fromJson(x)),
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> addToFavorites(String id) async {
    try {
      final response = await _networkService.request(
        endpoints.addToFavorites(id),
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> removeFromFavorites(String id) async {
    try {
      final response = await _networkService.request(
        endpoints.removeFromFavorites(id),
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<ReportReasonsDto>> getReportReasons() async {
    try {
      final response = await _networkService.request(
        endpoints.getReportReasons,
        RequestMethod.get,
        enableCache: true,
      );

      return List<ReportReasonsDto>.from(
        response.data['data'].map((x) => ReportReasonsDto.fromJson(x)),
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<ReportReasonsDto>> getReportBookingReasons() async {
    try {
      final response = await _networkService.request(
        endpoints.getReportBookingReasons,
        RequestMethod.get,
        enableCache: true,
      );

      return List<ReportReasonsDto>.from(
        response.data['data'].map((x) => ReportReasonsDto.fromJson(x)),
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> reportCreatorAccount(ReportAccountReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.reportUser,
        RequestMethod.post,
        data: req,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<SubscriptionsPlanDto>> getSubscriptionPlans() async {
    try {
      final response = await _networkService.request(
        endpoints.getSubscriptionPlans,
        RequestMethod.get,
        enableCache: true,
      );

      return List<SubscriptionsPlanDto>.from(
        response.data['data'].map((x) => SubscriptionsPlanDto.fromJson(x)),
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<MakeSubcriptionPaymentDto> makeSubscriptionPayment(String planId) async {
    try {
      final response = await _networkService.request(
        endpoints.makeSubscriptionPayment,
        RequestMethod.post,
        data: {
          'plan_id': planId,
        },
      );

      return MakeSubcriptionPaymentDto.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> verifySubscriptionPayment(String reference) async {
    try {
      final response = await _networkService.request(
        endpoints.verifySubscriptionPayment(reference),
        RequestMethod.get,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> cancelSubscription(String id) async {
    try {
      final response = await _networkService.request(
        endpoints.cancelSubscription(id),
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<MySubscriptionDto> getMySubscription() async {
    try {
      final response = await _networkService.request(
        endpoints.getMySubscription,
        RequestMethod.get,
      );

      return MySubscriptionDto.fromJson(response.data);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> toggleAutoRenewSubscription({
    required String id,
    required bool autoRenew,
  }) async {
    try {
      final response = await _networkService.request(
        endpoints.autoRenewSubscription(id),
        RequestMethod.post,
        data: {
          'auto_renew': autoRenew,
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<ReferralStats> getReferralStats() async {
    try {
      final response = await _networkService.request(
        endpoints.referralStats,
        RequestMethod.get,
      );

      return ReferralStats.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> claimReferralReward() async {
    try {
      final response = await _networkService.request(
        endpoints.claimReferralReward,
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> claimAmbassadorCommission() async {
    try {
      final response = await _networkService.request(
        endpoints.claimAmbassadorCommission,
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<AmbassadorStats> getAmbassadorReferredUsers() async {
    try {
      final response = await _networkService.request(
        endpoints.ambassadorStats,
        RequestMethod.get,
      );

      return AmbassadorStats.fromJson(response.data);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> updateProfile(String? referralCode, String? countryCode) async {
    try {
      final response = await _networkService.request(
        endpoints.updateProfile,
        RequestMethod.post,
        data: {
          if (referralCode != null) 'referral_code': referralCode,
          if (countryCode != null) 'country_code': countryCode,
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<StripeOnboardDto> stripeOnboardCreator() async {
    try {
      final response = await _networkService.request(
        endpoints.onboardCreatorToStripe,
        RequestMethod.post,
      );

      return StripeOnboardDto.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<StripeDashboardDto> getStripeDashboardLink() async {
    try {
      final response = await _networkService.request(
        endpoints.dashboardLogin,
        RequestMethod.get,
      );

      return StripeDashboardDto.fromJson(response.data['data']);
    } on ApiException catch (e) {
      final data = e.responseData?['data'];
      if (data != null && data['requires_stripe_onboarding'] == true) {
        throw StripeOnboardingException(
          message: e.message,
          onboardingData: StripeOnboardingData.fromJson(data),
        );
      }
      throw e.toString();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<Category>> getPreferences() async {
    try {
      final response = await _networkService.request(
        endpoints.getPreferences,
        RequestMethod.get,
      );

      return List<Category>.from(
        response.data['data'].map((x) => Category.fromJson(x)),
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> updatePreferences(List<String> categoryIds) async {
    try {
      final response = await _networkService.request(
        endpoints.updatePreferences,
        RequestMethod.post,
        data: {
          'category_ids': categoryIds,
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }
}
