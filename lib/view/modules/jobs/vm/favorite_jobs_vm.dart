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
        // We don't necessarily want to refetch all jobs here as it might be expensive,
        // but it ensures UI consistency if we navigate back to search.
      }
    });
  }

  @override
  FutureOr<void> build() {}
}

final toggleFavoriteJobProvider = AsyncNotifierProvider.autoDispose<ToggleFavoriteJobNotifier, void>(
  ToggleFavoriteJobNotifier.new,
);
