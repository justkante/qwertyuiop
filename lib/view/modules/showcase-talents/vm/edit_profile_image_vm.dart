import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/filter_creators_vm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EditProfileImageNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> editProfileImage(String filePath) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(creatorRepository).uploadProfileImage(filePath));

    if (!state.hasError) {
      final userId = ref.read(userControllerProvider).id ?? '';
      ref.invalidate(fetchCreatorProfileProvider(userId));
      ref.invalidate(fetchRecruiterProfileProvider(userId));
      ref.read(userControllerProvider.notifier).refreshUser();
      ref.read(filterCreatorsProvider.notifier).filterCreators();
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final editProfileImageProvider = AutoDisposeAsyncNotifierProvider<EditProfileImageNotifier, String>(
  EditProfileImageNotifier.new,
);
