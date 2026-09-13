import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/responses/onboard_stripe_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StripeCreatorOnboardNotifier extends AutoDisposeAsyncNotifier<StripeOnboardDto> {
  Future<void> stripeCreatorOnboard() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(creatorRepository).stripeOnboardCreator());

    if (!state.hasError) {}
  }

  @override
  FutureOr<StripeOnboardDto> build() {
    return StripeOnboardDto();
  }
}

final stripeCreatorOnboardProvider =
    AutoDisposeAsyncNotifierProvider<StripeCreatorOnboardNotifier, StripeOnboardDto>(
  StripeCreatorOnboardNotifier.new,
);
