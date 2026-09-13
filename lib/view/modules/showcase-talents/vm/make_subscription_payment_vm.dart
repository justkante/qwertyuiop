import 'dart:async';
import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/responses/make_subcription_payment_dto.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/filter_creators_vm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Make Subscription Payment Notifier
class MakeSubscriptionPaymentNotifier extends AutoDisposeAsyncNotifier<MakeSubcriptionPaymentDto> {
  Future<void> makeSubscriptionPayment(String planId) async {
    state = const AsyncValue.loading();

    state =
        await AsyncValue.guard(() => ref.read(creatorRepository).makeSubscriptionPayment(planId));

    if (!state.hasError) {}
  }

  @override
  FutureOr<MakeSubcriptionPaymentDto> build() {
    return MakeSubcriptionPaymentDto();
  }
}

final makeSubscriptionPaymentProvider =
    AutoDisposeAsyncNotifierProvider<MakeSubscriptionPaymentNotifier, MakeSubcriptionPaymentDto>(
  MakeSubscriptionPaymentNotifier.new,
);

// Verify Subscription Payment Notifier
class VerifySubscriptionPaymentNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> verifySubscriptionPayment(String paymentReference) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
        () => ref.read(creatorRepository).verifySubscriptionPayment(paymentReference));

    if (!state.hasError) {
      ref.invalidate(fetchCreatorProfileProvider);
      ref.read(filterCreatorsProvider.notifier).filterCreators();
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final verifySubscriptionPaymentProvider =
    AutoDisposeAsyncNotifierProvider<VerifySubscriptionPaymentNotifier, String>(
  VerifySubscriptionPaymentNotifier.new,
);

// Cancel Subscription Notifier
class CancelSubscriptionNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> cancelSubscription(String subscriptionId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
        () => ref.read(creatorRepository).cancelSubscription(subscriptionId));

    if (!state.hasError) {
      ref.invalidate(fetchCreatorProfileProvider);
      ref.invalidate(fetchMySubscriptionProvider);
      ref.read(filterCreatorsProvider.notifier).filterCreators();
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final cancelSubscriptionProvider =
    AutoDisposeAsyncNotifierProvider<CancelSubscriptionNotifier, String>(
  CancelSubscriptionNotifier.new,
);

// Auto Renew Subscription Notifier
class AutoRenewSubscriptionNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> toggleAutoRenewSubscription({required String id, required bool autoRenew}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() =>
        ref.read(creatorRepository).toggleAutoRenewSubscription(id: id, autoRenew: autoRenew));

    if (!state.hasError) {
      ref.invalidate(fetchMySubscriptionProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final autoRenewSubscriptionProvider =
    AutoDisposeAsyncNotifierProvider<AutoRenewSubscriptionNotifier, String>(
  AutoRenewSubscriptionNotifier.new,
);
