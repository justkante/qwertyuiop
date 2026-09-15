import 'dart:async';
import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/responses/job_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'job_controller.dart';

final fetchFavoriteJobsProvider = FutureProvider.autoDispose<List<JobDto>>((ref) async {
  final apiService = ref.watch(jobApiProvider);
  final response = await apiService.getFavoriteJobs();
  if (response.data['success']) {
    final List<dynamic> data = response.data['data'];
    return data.map((e) => JobDto.fromJson(e)).toList();
  }
  return [];
});

class ToggleFavoriteJobNotifier extends AutoDisposeAsyncNotifier<void> {
  Future<void> toggleFavorite(String jobId) async {
    state = const AsyncValue.loading();
    final apiService = ref.read(jobApiProvider);
    state = await AsyncValue.guard(() async {
      final response = await apiService.toggleFavorite(jobId);
      if (response.data['success']) {
        ref.invalidate(fetchFavoriteJobsProvider);

        // Also update the jobController state if it's currently holding this job
        final isFavorited = response.data['is_favorited'];
        final jobController = ref.read(jobControllerProvider.notifier);
        jobController.state = jobController.state.copyWith(
          jobs: jobController.state.jobs.map((j) {
            if (j.id == jobId) {
              return j.copyWith(isFavorited: isFavorited);
            }
            return j;
          }).toList(),
        );
      }
    });
  }

  @override
  FutureOr<void> build() {}
}

final toggleFavoriteJobProvider = AsyncNotifierProvider.autoDispose<ToggleFavoriteJobNotifier, void>(
  ToggleFavoriteJobNotifier.new,
);
