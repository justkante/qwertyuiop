import 'dart:developer';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/storage/hive-storage/hive_storage.dart';
import 'package:creatify_mobile/core/storage/hive-storage/hive_storage_service.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/responses/countries_dto.dart';
import 'package:creatify_mobile/data/models/responses/user_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider to track if user is being loaded from storage
final isLoadingUserProvider = StateProvider<bool>((ref) => true);

class UserController extends StateNotifier<UserDto> {
  final Ref ref;
  final HiveStorageBase storageService;

  UserController(this.ref, this.storageService) : super(UserDto());

  void setUser(UserDto user) {
    state = user;
    saveUserToStorage(user);
  }

  Future<void> refreshUser() async {
    try {
      final user = await ref.read(authRepository).getMe();
      state = user;
      await saveUserToStorage(user);
    } catch (e) {
      log('Error refreshing user data: $e');
    }
  }

  void updateReferredByCode(String referredByCode) async {
    state = state.copyWith(
      referredByCode: referredByCode,
      hasUsedReferralCode: true,
    );
    await saveUserToStorage(state);
  }

  void updateCountry(CountriesItemDto country) async {
    state = state.copyWith(
      countryCode: country.code,
      countryFlag: country.flagEmoji,
      primaryCurrency: country.currency,
      countryUpdatedAt: DateTime.now(),
    );

    SharedPrefManager.countryUpdatedAt = DateTime.now().toIso8601String();
    await saveUserToStorage(state);
  }

  Future<void> saveUserToStorage(UserDto user) async {
    try {
      await storageService.set(StorageKey.userProfileData.name, user);
      log('User saved to storage: ${user.name ?? ""}, id: ${user.id}');
    } catch (e) {
      log('Error saving user to storage: $e');
    }
  }

  Future<void> getUserFromStorage() async {
    try {
      final result = storageService.get(StorageKey.userProfileData.name);
      if (result != null && result is UserDto) {
        log('User loaded from storage: ${result.name ?? ""}, id: ${result.id}');
        state = result;
      } else {
        log('No user found in storage or invalid data');
        state = UserDto();
      }
    } catch (e) {
      log('Error loading user from storage: $e');
      state = UserDto();
    } finally {
      // Mark loading as complete
      ref.read(isLoadingUserProvider.notifier).state = false;
    }
  }

  Future<void> cleatUserFromStorage() async {
    try {
      await storageService.remove(StorageKey.userProfileData.name);
      log('User data cleared from storage');
    } catch (e) {
      log('Error clearing user from storage: $e');
    }
  }
}

final userControllerProvider = StateNotifierProvider<UserController, UserDto>(
  (ref) {
    final hiveStorage = ref.watch(hiveStorageService);

    return UserController(ref, hiveStorage);
  },
);
