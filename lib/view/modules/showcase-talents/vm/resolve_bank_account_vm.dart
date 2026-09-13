import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/requests/resolve_bank_acct_req.dart';
import 'package:creatify_mobile/data/models/responses/resolved_bank_acct_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ResolveBankAccountNotifier extends AutoDisposeAsyncNotifier<ResolvedBankAccountDto> {
  Future<void> resolveBankAccount(ResolveBankAccountReq req) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(creatorRepository).resolveBankAccount(req));
  }

  @override
  FutureOr<ResolvedBankAccountDto> build() {
    return ResolvedBankAccountDto();
  }
}

final resolveBankAccountProvider =
    AutoDisposeAsyncNotifierProvider<ResolveBankAccountNotifier, ResolvedBankAccountDto>(
  ResolveBankAccountNotifier.new,
);
