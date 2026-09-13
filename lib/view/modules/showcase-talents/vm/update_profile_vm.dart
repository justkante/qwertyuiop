import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/responses/countries_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UpdateProfileNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> updateProfile({String? referralCode, CountriesItemDto? country}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref
        .read(creatorRepository)
        .updateProfile(referralCode: referralCode, countryCode: country?.code));

    if (!state.hasError) {
      if (referralCode != null) {
        ref.read(userControllerProvider.notifier).updateReferredByCode(referralCode);
      }
      if (country != null) {
        ref.read(userControllerProvider.notifier).updateCountry(country);
      }
    }
    // else {
    //   // Handle specific error for country update
    //   if (state.error.toString().contains('cannot be changed') && country != null) {
    //     ref.read(userControllerProvider.notifier).updateCountry(country);
    //   }
    // }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final updateProfileProvider = AutoDisposeAsyncNotifierProvider<UpdateProfileNotifier, String>(
  UpdateProfileNotifier.new,
);
