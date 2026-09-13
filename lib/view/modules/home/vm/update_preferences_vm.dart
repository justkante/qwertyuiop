import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/filter_creators_vm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UpdatePreferencesNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> updatePreferences(List<String> categoryIds) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(creatorRepository).updatePreferences(categoryIds),
    );

    if (!state.hasError) {
      ref.invalidate(getRecommendedCreatorsProvider);
      mixpanel.trackEvent('Preferences Updated');
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final updatePreferencesProvider =
    AutoDisposeAsyncNotifierProvider<UpdatePreferencesNotifier, String>(
  UpdatePreferencesNotifier.new,
);
