import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/requests/update_availability_req.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UpdateAvailabilityNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> updateAvailability(UpdateAvailabilityReq req) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(creatorRepository).updateAvailability(req));

    if (!state.hasError) {
      ref.invalidate(getOnboardingStatusProvider);
      ref.invalidate(fetchAvailabilityProvider);
      ref.invalidate(fetchCreatorProfileProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final updateAvailabilityProvider =
    AutoDisposeAsyncNotifierProvider<UpdateAvailabilityNotifier, String>(
  UpdateAvailabilityNotifier.new,
);
