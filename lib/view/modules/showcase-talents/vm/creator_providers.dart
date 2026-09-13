import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/responses/creator_availabiity_dto.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/data/models/responses/recruiter_profile_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final getOnboardingStatusProvider = FutureProvider.autoDispose((ref) async {
  return await ref.watch(creatorRepository).getOnboardingStatus();
});

final fetchBanksProvider = FutureProvider((ref) async {
  return await ref.watch(creatorRepository).getBanks();
});

final fetchStatesProvider = FutureProvider((ref) async {
  return await ref.watch(creatorRepository).getStates();
});

final fetchCreatorNichesProvider = FutureProvider((ref) async {
  return await ref.watch(creatorRepository).getCreatorNiches();
});

final fetchGroupedCreatorNichesProvider = FutureProvider((ref) async {
  return await ref.watch(creatorRepository).getGroupedCreatorNiches();
});

final fetchPayoutDetailsProvider = FutureProvider.autoDispose((ref) async {
  return await ref.watch(creatorRepository).getPayoutDetails();
});

final fetchPortfolioProvider = FutureProvider.autoDispose((ref) async {
  return await ref.watch(creatorRepository).getPortfolio();
});

final fetchAvailabilityProvider = FutureProvider.autoDispose
    .family<CreatorAvailabilityDto, (int year, int month)>((ref, args) async {
  return await ref.watch(creatorRepository).getCreatorAvailability(year: args.$1, month: args.$2);
});

final fetchCreatorProfileProvider =
    FutureProvider.autoDispose.family<CreatorProfileDto, String>((ref, id) async {
  return await ref.watch(creatorRepository).getCreatorProfile(id);
});

final fetchRecruiterProfileProvider =
    FutureProvider.autoDispose.family<RecruiterProfileDto, String>((ref, id) async {
  return await ref.watch(creatorRepository).getRecruiterProfile(id);
});

final fetchFavoriteCreatorsProvider = FutureProvider.autoDispose((ref) async {
  return await ref.watch(creatorRepository).getFavoriteCreators();
});

final fetchReportReasonsProvider = FutureProvider((ref) async {
  return await ref.watch(creatorRepository).getReportReasons();
});

final fetchReportBookingsReasonsProvider = FutureProvider((ref) async {
  return await ref.watch(creatorRepository).getReportBookingReasons();
});

// Provider to filter creators based on search criteria
final hasSearchFiltersProvider = StateProvider<bool>((ref) {
  return false;
});

final fetchSubscriptionPlansProvider = FutureProvider((ref) async {
  return await ref.watch(creatorRepository).getSubscriptionPlans();
});

final fetchMySubscriptionProvider = FutureProvider.autoDispose((ref) async {
  return await ref.watch(creatorRepository).getMySubscription();
});

final fetchReferralStatsProvider = FutureProvider.autoDispose((ref) async {
  return await ref.watch(creatorRepository).getReferralStats();
});

final getCreatorDashboardProvider = FutureProvider.autoDispose((ref) async {
  return await ref.watch(creatorRepository).getStripeDashboardLink();
});

final fetchPreferencesProvider = FutureProvider.autoDispose((ref) async {
  return await ref.watch(creatorRepository).getPreferences();
});

final fetchReferredUsersProvider = FutureProvider.autoDispose((ref) async {
  return await ref.watch(creatorRepository).getAmbassadorReferredUsers();
});
