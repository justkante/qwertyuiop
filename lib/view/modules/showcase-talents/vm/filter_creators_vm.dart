import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
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

    state = await AsyncValue.guard(
      () => ref.read(creatorRepository).filterCreators(
            name: name,
            priceMin: priceMin?.toString(),
            priceMax: priceMax?.toString(),
            category: category,
            location: location,
          ),
    );

    if (!state.hasError) {
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
    }
  }

  @override
  FutureOr<List<CreatorProfileDto>> build() {
    return ref.read(creatorRepository).filterCreators();
  }
}

final filterCreatorsProvider =
    AutoDisposeAsyncNotifierProvider<FilterCreatorsNotifier, List<CreatorProfileDto>>(
  FilterCreatorsNotifier.new,
);

final getRecommendedCreatorsProvider = FutureProvider.autoDispose((ref) async {
  return await ref.watch(creatorRepository).recommendedCreators();
});
