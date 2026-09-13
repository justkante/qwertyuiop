import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UploadPortfolioItemNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> uploadToPortfolio(Map<String, dynamic> portfolioData) async {
    state = const AsyncValue.loading();

    state =
        await AsyncValue.guard(() => ref.read(creatorRepository).uploadPortfolio(portfolioData));

    if (!state.hasError) {
      ref.invalidate(fetchPortfolioProvider);
      ref.invalidate(getOnboardingStatusProvider);
      ref.invalidate(fetchCreatorProfileProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final uploadToPortfolioProvider =
    AutoDisposeAsyncNotifierProvider<UploadPortfolioItemNotifier, String>(
  UploadPortfolioItemNotifier.new,
);

// Delete Portfolio Item
class DeletePortfolioItemNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> deletePortfolioItem(String portfolioId) async {
    state = const AsyncValue.loading();

    state =
        await AsyncValue.guard(() => ref.read(creatorRepository).deletePortfolioItem(portfolioId));

    if (!state.hasError) {
      ref.invalidate(getOnboardingStatusProvider);
      ref.invalidate(fetchPortfolioProvider);
      ref.invalidate(fetchCreatorProfileProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final deletePortfolioItemProvider =
    AutoDisposeAsyncNotifierProvider<DeletePortfolioItemNotifier, String>(
  DeletePortfolioItemNotifier.new,
);

// Skip Portfolio
class SkipPortfolioNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> skipPortfolio() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(creatorRepository).skipPortfolioUpload());

    if (!state.hasError) {
      ref.invalidate(getOnboardingStatusProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final skipPortfolioProvider = AutoDisposeAsyncNotifierProvider<SkipPortfolioNotifier, String>(
  SkipPortfolioNotifier.new,
);
