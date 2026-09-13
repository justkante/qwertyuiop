import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ClaimAmbassadorCommissionNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> claimAmbassadorCommission() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(creatorRepository).claimAmbassadorCommission());
    if (!state.hasError) {
      ref.invalidate(fetchReferredUsersProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final claimAmbassadorCommissionProvider =
    AutoDisposeAsyncNotifierProvider<ClaimAmbassadorCommissionNotifier, String>(
  ClaimAmbassadorCommissionNotifier.new,
);
