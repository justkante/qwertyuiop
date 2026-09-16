import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/core/utils/profile_strength_utils.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FilterCreatorsNotifier extends AutoDisposeAsyncNotifier<List<CreatorProfileDto>> {
  Future<void> filterCreators({
    String? name,
    double? priceMin,
    double? priceMax,
    String? category,
    String? location,
  }) async {
    state = const AsyncValue.loading();

    final response = await AsyncValue.guard(
      () => ref.read(creatorRepository).filterCreators(
            name: name,
            priceMin: priceMin?.toString(),
            priceMax: priceMax?.toString(),
            category: category,
            location: location,
          ),
    );

    if (!response.hasError) {
      final list = response.value ?? [];
      // Sort by profile strength descending
      list.sort((a, b) {
        final strengthA = ProfileStrengthUtils.calculateStrengthForProfile(a);
        final strengthB = ProfileStrengthUtils.calculateStrengthForProfile(b);
        return strengthB.compareTo(strengthA);
      });
      state = AsyncValue.data(list);

      // Track Login Event
      mixpanel.trackEvent(
        'Search/Filter Performed',
        properties: {
          if (name != null) 'name': name,
          if (priceMin != null) 'price_min': priceMin,
          if (priceMax != null) 'price_max': priceMax,
          if (category != null) 'category': category,
          if (location != null) 'location': location,
        },
      );
    } else {
      state = response;
    }
  }

  @override
  FutureOr<List<CreatorProfileDto>> build() async {
    final list = await ref.read(creatorRepository).filterCreators();
    list.sort((a, b) {
      final strengthA = ProfileStrengthUtils.calculateStrengthForProfile(a);
      final strengthB = ProfileStrengthUtils.calculateStrengthForProfile(b);
      return strengthB.compareTo(strengthA);
    });
    return list;
  }
}

final filterCreatorsProvider =
    AutoDisposeAsyncNotifierProvider<FilterCreatorsNotifier, List<CreatorProfileDto>>(
  FilterCreatorsNotifier.new,
);

final getRecommendedCreatorsProvider = FutureProvider.autoDispose((ref) async {
  return await ref.watch(creatorRepository).recommendedCreators();
});
