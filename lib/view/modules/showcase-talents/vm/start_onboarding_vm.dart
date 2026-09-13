import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StartOnboardingNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> startOnboarding() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(creatorRepository).startOnboarding());

    if (!state.hasError) {
      ref.invalidate(getOnboardingStatusProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final startOnboardingProvider = AutoDisposeAsyncNotifierProvider<StartOnboardingNotifier, String>(
  StartOnboardingNotifier.new,
);
