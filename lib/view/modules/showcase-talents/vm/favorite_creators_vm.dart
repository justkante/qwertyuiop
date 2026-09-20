import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/view/modules/search-talents/talent_filter_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/filter_creators_vm.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AddToFavoriteCreatorsNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> addToFavoriteCreators(String creatorId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(creatorRepository).addToFavorites(creatorId));

    if (!state.hasError) {
      ref.invalidate(fetchFavoriteCreatorsProvider);
      ref.read(filterCreatorsProvider.notifier).filterCreators();
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final addToFavoriteCreatorsProvider =
    AutoDisposeAsyncNotifierProvider<AddToFavoriteCreatorsNotifier, String>(
  AddToFavoriteCreatorsNotifier.new,
);

// Remove From Favorite Creators
class RemoveFromFavoriteCreatorsNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> removeFromFavoriteCreators(String creatorId) async {
    state = const AsyncValue.loading();

    state =
        await AsyncValue.guard(() => ref.read(creatorRepository).removeFromFavorites(creatorId));

    if (!state.hasError) {
      ref.invalidate(fetchFavoriteCreatorsProvider);
      ref.read(filterCreatorsProvider.notifier).filterCreators();
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final removeFromFavoriteCreatorsProvider =
    AutoDisposeAsyncNotifierProvider<RemoveFromFavoriteCreatorsNotifier, String>(
  RemoveFromFavoriteCreatorsNotifier.new,
);
