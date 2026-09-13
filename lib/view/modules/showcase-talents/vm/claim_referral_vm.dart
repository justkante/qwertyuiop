import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ClaimReferralRewardNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> claimReferralReward() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(creatorRepository).claimReferralReward());
    if (!state.hasError) {
      ref.invalidate(fetchReferralStatsProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final claimReferralRewardProvider =
    AutoDisposeAsyncNotifierProvider<ClaimReferralRewardNotifier, String>(
  ClaimReferralRewardNotifier.new,
);
