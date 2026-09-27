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

    try {
      List<CreatorProfileDto> list = [];
      try {
        list = await ref.read(creatorRepository).filterCreators(
              name: name,
              priceMin: priceMin?.toString(),
              priceMax: priceMax?.toString(),
              category: category,
              location: location,
            );
      } catch (_) {}

      if (list.isEmpty || (location != null && location.isNotEmpty) || (name != null && name.isNotEmpty) || (category != null && category.isNotEmpty)) {
        final allCreators = await ref.read(creatorRepository).filterCreators();

        list = allCreators.where((creator) {
          bool matchesName = true;
          bool matchesLocation = true;
          bool matchesCategory = true;

          if (name != null && name.isNotEmpty) {
            final q = name.toLowerCase();
            matchesName = (creator.name?.toLowerCase().contains(q) ?? false) ||
                          (creator.categories?.any((c) => c.name?.toLowerCase().contains(q) ?? false) ?? false);
          }

          if (location != null && location.isNotEmpty) {
            final locLower = location.toLowerCase();
            final creatorLoc = creator.location?.toLowerCase() ?? '';
            final country = creator.countryCode?.toLowerCase() ?? '';
            matchesLocation = creatorLoc.contains(locLower) || country.contains(locLower) || creatorLoc.contains(locLower.replaceAll(' ', ''));
          }

          if (category != null && category.isNotEmpty) {
            final catLower = category.toLowerCase();
            matchesCategory = creator.categories?.any((c) => c.name?.toLowerCase().contains(catLower) ?? false) ?? false;
          }

          return matchesName && matchesLocation && matchesCategory;
        }).toList();
      }

      // Sort by profile strength descending
      list.sort((a, b) {
        final strengthA = ProfileStrengthUtils.calculateStrengthForProfile(a);
        final strengthB = ProfileStrengthUtils.calculateStrengthForProfile(b);
        return strengthB.compareTo(strengthA);
      });
      state = AsyncValue.data(list);

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
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
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
