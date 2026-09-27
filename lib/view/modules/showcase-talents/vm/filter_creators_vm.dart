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
    double? rating,
    String? availability,
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

      if (list.isEmpty || (location != null && location.isNotEmpty) || (name != null && name.isNotEmpty) || (category != null && category.isNotEmpty) || (rating != null) || (availability != null && availability.isNotEmpty)) {
        final allCreators = await ref.read(creatorRepository).filterCreators();

        list = allCreators.where((creator) {
          bool matchesName = true;
          bool matchesLocation = true;
          bool matchesCategory = true;
          bool matchesRating = true;
          bool matchesAvailability = true;

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

          if (rating != null) {
            final avgRating = creator.ratingsAndReviews?.averageRating ?? 0.0;
            final totalReviews = creator.ratingsAndReviews?.totalReviews ?? 0;
            if (rating == -1.0) {
              matchesRating = totalReviews == 0;
            } else if (rating > 0) {
              matchesRating = avgRating >= rating;
            }
          }

          if (availability != null && availability.isNotEmpty) {
            final lastActive = creator.lastSeenAt?.toLowerCase() ?? '';
            if (availability == 'Available now') {
              matchesAvailability = lastActive.contains('just now') || lastActive.contains('online') || lastActive.contains('m ago') || lastActive.contains('h ago');
            } else {
              matchesAvailability = true;
            }
          }

          return matchesName && matchesLocation && matchesCategory && matchesRating && matchesAvailability;
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
          if (rating != null) 'rating': rating,
          if (availability != null) 'availability': availability,
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
