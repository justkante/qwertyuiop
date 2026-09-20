import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/responses/job_dto.dart';
import 'package:creatify_mobile/data/models/responses/recent_search_dto.dart';
import 'package:creatify_mobile/data/models/responses/job_application_dto.dart';
import 'package:creatify_mobile/data/models/responses/fund_wallet_dto.dart';
import 'package:creatify_mobile/core/error/api_exception.dart';
import 'package:creatify_mobile/view/modules/jobs/vm/favorite_jobs_vm.dart';
import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'job_service.dart';

class JobState {
  final List<JobDto> jobs;
  final List<RecentSearchDto> recentSearches;
  final List<JobApplicationDto> applications;
  final bool isLoading;
  final String searchQuery;

  JobState({
    this.jobs = const [],
    this.recentSearches = const [],
    this.applications = const [],
    this.isLoading = false,
    this.searchQuery = '',
  });

  JobState copyWith({
    List<JobDto>? jobs,
    List<RecentSearchDto>? recentSearches,
    List<JobApplicationDto>? applications,
    bool? isLoading,
    String? searchQuery,
  }) {
    return JobState(
      jobs: jobs ?? this.jobs,
      recentSearches: recentSearches ?? this.recentSearches,
      applications: applications ?? this.applications,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class JobController extends StateNotifier<JobState> {
  final JobApiService _apiService;
  final Ref _ref;

  JobController(this._apiService, this._ref) : super(JobState()) {
    fetchRecentSearches();
    fetchJobs();
  }

  Future<void> fetchRecentSearches() async {
    try {
      final response = await _apiService.getRecentSearches();
      if (response.data['success']) {
        final List<dynamic> data = response.data['data'];
        state = state.copyWith(
          recentSearches: data.map((e) => RecentSearchDto.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addSearch(String query) async {
    if (query.isEmpty) return;
    try {
      await _apiService.saveRecentSearch(query);
      fetchRecentSearches();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> clearSearches() async {
    try {
      await _apiService.clearRecentSearches();
      state = state.copyWith(recentSearches: []);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeSearch(String id) async {
    try {
      await _apiService.deleteRecentSearch(id);
      state = state.copyWith(
        recentSearches: state.recentSearches.where((s) => s.id != id).toList(),
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchJobs({Map<String, dynamic>? filters}) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.getJobs(filters ?? {});
      if (response.data['success']) {
        final data = response.data['data'];
        final List<dynamic> jobList = (data is Map && data['data'] != null)
            ? data['data']
            : (data is List ? data : []);

        state = state.copyWith(
          jobs: jobList.map((e) => JobDto.fromJson(e)).toList(),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, jobs: []);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, jobs: []);
    }
  }

  Future<void> toggleFavorite(String jobId) async {
    try {
      final response = await _apiService.toggleFavorite(jobId);
      if (response.data['success']) {
        final isFavorited = response.data['is_favorited'];
        state = state.copyWith(
          jobs: state.jobs.map((j) {
            if (j.id == jobId) {
              return j.copyWith(isFavorited: isFavorited);
            }
            return j;
          }).toList(),
        );

        // Invalidate favorites provider so it refreshes when user navigates to Favourites screen
        _ref.invalidate(fetchFavoriteJobsProvider);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchAppliedJobs() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.getAppliedJobs();
      if (response.data['success']) {
        final List<dynamic> data = response.data['data'] ?? [];
        state = state.copyWith(
          jobs: data.map((e) => JobDto.fromJson(e['job'])).toList(),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, jobs: []);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, jobs: []);
    }
  }

  Future<void> fetchMyListings() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.getMyListings();
      if (response.data['success']) {
        final List<dynamic> data = response.data['data'] ?? [];
        state = state.copyWith(
          jobs: data.map((e) => JobDto.fromJson(e)).toList(),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, jobs: []);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, jobs: []);
    }
  }

  Future<String?> createJob(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.createJob(data);
      state = state.copyWith(isLoading: false);
      if (response.data['success']) {
        fetchMyListings();
        return null;
      }
      // Return specific error from backend if available
      final errors = response.data?['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        return firstError.toString();
      }
      return response.data?['message']?.toString() ?? 'Failed to post job';
    } catch (e) {
      state = state.copyWith(isLoading: false);
      if (e is ApiException) {
        if (e.responseData != null && e.responseData!['errors'] is Map) {
          final errors = e.responseData!['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            }
            return firstError.toString();
          }
        }
        return e.message;
      }
      return e.toString();
    }
  }

  Future<String?> applyToJob(String jobId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      // Prevent applying to own job
      final job = state.jobs.cast<JobDto?>().firstWhere((j) => j?.id == jobId, orElse: () => null);
      if (job != null && job.userId == _ref.read(userControllerProvider).id) {
        state = state.copyWith(isLoading: false);
        return 'You cannot apply to your own job';
      }

      final response = await _apiService.applyToJob(jobId, data);
      state = state.copyWith(isLoading: false);
      if (response.data != null && response.data is Map && response.data['success'] == true) {
        return null;
      }

      final message = response.data?['message']?.toString();
      final errors = response.data?['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        return firstError.toString();
      }
      return message ?? 'Failed to submit application';
    } catch (e) {
      state = state.copyWith(isLoading: false);
      if (e is ApiException) {
        if (e.responseData != null && e.responseData!['errors'] is Map) {
          final errors = e.responseData!['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            }
            return firstError.toString();
          }
        }
        return e.message;
      }
      return e.toString();
    }
  }

  Future<void> fetchApplications(String jobId) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.getJobApplications(jobId);
      if (response.data['success']) {
        final List<dynamic> data = response.data['data'];
        state = state.copyWith(
          applications: data.map((e) => JobApplicationDto.fromJson(e)).toList(),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> respondToApplication(String applicationId, String status, {String? paymentReference}) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.respondToApplication(applicationId, {
        'status': status,
        if (paymentReference != null) 'payment_reference': paymentReference,
      });
      state = state.copyWith(isLoading: false);
      if (response.data['success']) {
        state = state.copyWith(
          applications: state.applications.map((a) {
            if (a.id == applicationId) {
              return a.copyWith(status: status);
            }
            return a;
          }).toList(),
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<String?> closeJob(String jobId) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.closeJob(jobId);
      state = state.copyWith(isLoading: false);
      if (response.data != null && response.data is Map && response.data['success'] == true) {
        fetchMyListings();
        fetchJobs();
        return null;
      }
      return response.data?['message']?.toString() ?? 'Failed to close job';
    } catch (e) {
      state = state.copyWith(isLoading: false);
      if (e is ApiException) {
        return e.message;
      }
      return e.toString();
    }
  }

  Future<String?> deleteJob(String jobId) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.deleteJob(jobId);
      state = state.copyWith(isLoading: false);
      if (response.data != null && response.data is Map && response.data['success'] == true) {
        fetchMyListings();
        fetchJobs();
        return null;
      }
      return response.data?['message']?.toString() ?? 'Failed to delete job';
    } catch (e) {
      state = state.copyWith(isLoading: false);
      if (e is ApiException) {
        return e.message;
      }
      return e.toString();
    }
  }
}

final jobControllerProvider = StateNotifierProvider<JobController, JobState>((ref) {
  return JobController(ref.watch(jobApiProvider), ref);
});

// Provider to control the internal tab index of JobsMainView
final jobTabIndexProvider = StateProvider<int>((ref) => 0);

final initializeJobPaymentProvider =
    AutoDisposeAsyncNotifierProvider<InitializeJobPaymentNotifier, FundWalletDto>(
  InitializeJobPaymentNotifier.new,
);

class InitializeJobPaymentNotifier extends AutoDisposeAsyncNotifier<FundWalletDto> {
  @override
  FutureOr<FundWalletDto> build() {
    return FundWalletDto();
  }

  Future<void> initializePayment(String applicationId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(jobApiProvider).initializeJobApplicationPayment(applicationId);
      return FundWalletDto.fromJson(response.data['data']);
    });
  }
}
