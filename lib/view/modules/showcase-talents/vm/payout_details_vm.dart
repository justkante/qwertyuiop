import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/requests/save_payout_details_req.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SavePayoutDetailsNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> payoutOnboarding(SavePayoutDetailsReq req) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(creatorRepository).savePayoutDetails(req));

    if (!state.hasError) {
      ref.invalidate(getOnboardingStatusProvider);
      ref.invalidate(fetchCreatorProfileProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final savePayoutDetailsProvider =
    AutoDisposeAsyncNotifierProvider<SavePayoutDetailsNotifier, String>(
  SavePayoutDetailsNotifier.new,
);
