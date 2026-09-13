import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/responses/transaction_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// final getTransactionsProvider = FutureProvider<TransactionDto>((ref) async {
//   final repo = ref.read(transactionsRepository);
//   return await repo.getTransactions();
// });

final getTransactionDetailsProvider =
    FutureProvider.autoDispose.family<TransactionItemDto, String>((ref, transactionId) async {
  final repo = ref.read(transactionsRepository);
  return await repo.getTransactionDetails(transactionId);
});

final fetchWalletDetailsProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.read(transactionsRepository);
  final walletDetails = await repo.getwalletDetails();

  // Pass the waller balancen from the repo
  ref.watch(walletBalanceProvider.notifier).state = walletDetails.availableBalance ?? 0;

  return walletDetails;
});

// Provider to hold Wallet Balance
final walletBalanceProvider = StateProvider<num>((ref) => 0);

// Provider to hide and show balance
final balanceVisibleController = StateNotifierProvider<BalanceVisibilityNotifier, bool>(
  (ref) => BalanceVisibilityNotifier(),
);

class BalanceVisibilityNotifier extends StateNotifier<bool> {
  BalanceVisibilityNotifier() : super(SharedPrefManager.balanceVisible);

  void toggle() {
    state = !state;
    SharedPrefManager.balanceVisible = state;
  }
}
