import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/requests/rates_card_req.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/filter_creators_vm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SaveVirtualRateCardNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> createVirtualRateCard(RatesCardReq req) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(creatorRepository).saveVirtualRateCard(req));

    if (!state.hasError) {
      ref.invalidate(getOnboardingStatusProvider);
      ref.invalidate(fetchCreatorProfileProvider);
      ref.read(filterCreatorsProvider.notifier).filterCreators();
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final saveVirtualRateCardProvider =
    AutoDisposeAsyncNotifierProvider<SaveVirtualRateCardNotifier, String>(
  SaveVirtualRateCardNotifier.new,
);
