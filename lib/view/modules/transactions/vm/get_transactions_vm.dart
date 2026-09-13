import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/responses/transaction_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GetTransactionsNotifier extends AutoDisposeAsyncNotifier<TransactionDto> {
  Future<void> getTransactions({
    String? category,
    String? status,
    String? minAmount,
    String? maxAmount,
    String? startDate,
    String? endDate,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(transactionsRepository).getTransactions(
            category: category,
            status: status,
            minAmount: minAmount,
            maxAmount: maxAmount,
            startDate: startDate,
            endDate: endDate,
          ),
    );
  }

  @override
  FutureOr<TransactionDto> build() {
    return ref.read(transactionsRepository).getTransactions();
  }
}

final getTransactionsProvider =
    AutoDisposeAsyncNotifierProvider<GetTransactionsNotifier, TransactionDto>(
  GetTransactionsNotifier.new,
);
