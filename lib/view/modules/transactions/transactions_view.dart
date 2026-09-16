import 'package:creatify_mobile/core/error/stripe_onboarding_exception.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/stripe_verification_info_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/transactions/all_transactions_view.dart';
import 'package:creatify_mobile/view/modules/transactions/sheets/fund_wallet_sheet.dart';
import 'package:creatify_mobile/view/modules/transactions/sheets/set_withdrawal_pin_sheet.dart';
import 'package:creatify_mobile/view/modules/transactions/sheets/withdrawal_sheet.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/get_transactions_vm.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/transactions_providers.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/wallet_funding_vm.dart';
import 'package:creatify_mobile/view/modules/transactions/widgets/incoming_outgoing_card.dart';
import 'package:creatify_mobile/view/modules/transactions/widgets/transaction_item.dart';
import 'package:creatify_mobile/view/modules/webview/app_webview.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView> {
  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final walletDetails = ref.watch(fetchWalletDetailsProvider);
    final transactionsAsync = ref.watch(getTransactionsProvider);
    final isBalanceVisible = ref.watch(balanceVisibleController);

    ref.listen(verifyWalletFundingProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('Wallet funded successfully', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Wallet',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24),
        ),
        actions: [
          _buildStripeRedirect(userData),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          ref.invalidate(fetchWalletDetailsProvider);
          ref.invalidate(getTransactionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MARK: Balance Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Available Balance', style: TextStyle(color: AppColors.body, fontSize: 13, fontWeight: FontWeight.w500)),
                          4.0.width,
                          const Icon(Icons.info_outline, size: 14, color: AppColors.body),
                          12.0.width,
                          GestureDetector(
                            onTap: () => ref.read(balanceVisibleController.notifier).toggle(),
                            child: Icon(
                              isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 18,
                              color: AppColors.body,
                            ),
                          ),
                        ],
                      ),
                      8.0.height,
                      Text(
                        isBalanceVisible
                            ? walletDetails.hasValue
                                ? walletDetails.value!.availableBalance.amountWithCurrency(userData.primaryCurrency ?? 'NGN')
                                : 0.amountWithCurrency(userData.primaryCurrency ?? 'NGN')
                            : '●●●●●●●●',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B3131),
                          fontFamily: 'Inter',
                        ),
                      ),
                      12.0.height,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF6EF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time, color: Color(0xFFF4A261), size: 14),
                            4.0.width,
                            Text(
                              'Pending Balance: ',
                              style: TextStyle(color: const Color(0xFFF4A261), fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              isBalanceVisible
                                  ? walletDetails.hasValue
                                      ? walletDetails.value!.pendingBalance.amountWithCurrency(userData.primaryCurrency ?? 'NGN')
                                      : 0.amountWithCurrency(userData.primaryCurrency ?? 'NGN')
                                  : '●●●●',
                              style: const TextStyle(color: Color(0xFF1B3131), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: MainButton(
                        text: 'Withdraw',
                        color: const Color(0xFFE0F2F1),
                        textColor: AppColors.primary,
                        onPressed: () => _handleWithdrawal(context),
                      ),
                    ),
                    12.0.width,
                    Expanded(
                      child: MainButton(
                        text: 'Fund Wallet',
                        onPressed: () => AppBottomSheet.showBottomSheet(context, widget: const FundWalletSheet()),
                      ),
                    ),
                  ],
                ),
              ),
              24.0.height,

              // Incoming / Outgoing Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: transactionsAsync.maybeWhen(
                  data: (data) => Row(
                    children: [
                      Expanded(
                        child: IncomingOutcomingCard(
                          isIncoming: true,
                          amount: (data.summary?.totalIncoming ?? 0).amountWithCurrency(userData.primaryCurrency ?? 'NGN'),
                        ),
                      ),
                      12.0.width,
                      Expanded(
                        child: IncomingOutcomingCard(
                          isIncoming: false,
                          amount: (data.summary?.totalOutgoing ?? 0).amountWithCurrency(userData.primaryCurrency ?? 'NGN'),
                        ),
                      ),
                    ],
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
              32.0.height,

              // Recent Transactions Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B3131))),
                    GestureDetector(
                      onTap: () => NavigationService.instance.push(const AllTransactionsView()),
                      child: const Text('View all', style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              8.0.height,

              // Transactions List
              transactionsAsync.when(
                data: (data) {
                  if (data.data == null || data.data!.isEmpty) return _buildEmptyState();
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.data!.length > 3 ? 3 : data.data!.length,
                    separatorBuilder: (_, __) => const Divider(color: AppColors.grey100, height: 1),
                    itemBuilder: (context, index) => TransactionItem(transaction: data.data![index]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                error: (e, s) => Center(child: Text(e.toString())),
              ),
              32.0.height,

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B3131))),
              ),
              16.0.height,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildQuickAction(Icons.assignment_outlined, 'Transaction\nhistory', () => NavigationService.instance.push(const AllTransactionsView())),
                    12.0.width,
                    _buildQuickAction(Icons.account_balance_wallet_outlined, 'Payout\naccount', () {}),
                    12.0.width,
                    _buildQuickAction(Icons.download_outlined, 'Download\nstatement', () {}),
                  ],
                ),
              ),
              40.0.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStripeRedirect(dynamic userData) {
    if (userData.primaryCurrency == 'NGN') return const SizedBox.shrink();
    return IconButton(
      onPressed: () {
        ref.read(getCreatorDashboardProvider.future).then((value) {
          if (context.mounted) NavigationService.instance.push(WebviewScreen(url: value.url ?? '', routeName: "Payout Dashboard"));
        }).catchError((e) {
          if (context.mounted) ToastDialog.showError(e.toString(), context);
        });
      },
      icon: Row(
        children: [
          const Text('stripe', style: TextStyle(color: Color(0xFF6772E5), fontWeight: FontWeight.bold, fontSize: 16)),
          2.0.width,
          const Icon(Icons.open_in_new, color: Color(0xFF6772E5), size: 16),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey100),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            8.0.width,
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF1B3131), height: 1.2),
              ),
            ),
            const Icon(Icons.chevron_right, size: 14, color: AppColors.body),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          40.0.height,
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(color: Colors.teal.shade50.withOpacity(0.3), shape: BoxShape.circle),
            child: const Icon(Icons.account_balance_wallet_outlined, size: 60, color: Color(0xFF00796B)),
          ),
          20.0.height,
          const Text('No transactions yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          8.0.height,
          const Text('Your incoming and outgoing payments\nwill appear here.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.body, fontSize: 13)),
          24.0.height,
          TextButton(
            onPressed: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_outlined, color: Color(0xFF00796B), size: 18),
                8.0.width,
                const Text('How payouts work  >', style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleWithdrawal(BuildContext context) {
    if (ref.read(fetchWalletDetailsProvider).value?.hasPin == false) {
      AppBottomSheet.showBottomSheet(context, widget: const SetWithdrawalPinSheet());
    } else {
      AppBottomSheet.showBottomSheet(context, widget: const WithdrawalSheet());
    }
  }
}
