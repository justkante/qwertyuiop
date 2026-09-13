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
import 'package:creatify_mobile/view/widgets/overlay_animation.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:creatify_mobile/view/utils/tour/guarded_showcase.dart';
import 'package:creatify_mobile/view/utils/tour/tour_keys.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView> {
  final searchController = TextEditingController();
  String searchQuery = '';
  Map<String, dynamic>? appliedFilters;

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
    });
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final walletDetails = ref.watch(fetchWalletDetailsProvider);
    final transactions = ref.watch(getTransactionsProvider);

    ref.listen(verifyWalletFundingProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('Wallet funded successfully', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wallets',
          style: context.textTheme.displayMedium?.copyWith(fontSize: 19),
        ),
        actions: userData.primaryCurrency == 'NGN'
            ? []
            : [
                InkWell(
                  onTap: () {
                    ref.invalidate(getCreatorDashboardProvider);
                    ref.read(getCreatorDashboardProvider.future).then((value) {
                      if (!context.mounted) return;

                      context.push(
                        WebviewScreen(
                          url: value.url ?? '',
                          routeName: "Payout Dashboard",
                        ),
                      );
                    }).catchError((error) {
                      if (!context.mounted) return;
                      ToastDialog.showError(error.toString(), context);
                      if (error is StripeOnboardingException) {
                        context.push(const StripeVerificationInfoView());
                      }
                    });
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppImages.stripe,
                        height: 36,
                      ),
                      SvgPicture.asset(
                        AppImages.openExternal,
                        colorFilter: AppColors.stripeColor.colorFilterMode(),
                        height: 24,
                      ),
                    ],
                  ),
                ),
                20.0.width,
              ],
      ),
      body: OverlayLoadingIndicator(
        isLoading: ref.watch(getCreatorDashboardProvider).isLoading,
        child: Column(
          children: [
            // MARK: Wallet Section
            GuardedShowcase(
              showcaseKey: TourKeys.walletBalance,
              description: 'View your available and pending balance at a glance.',
              targetBorderRadius: BorderRadius.circular(8),
              child: Column(
                children: [
                  12.0.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Balance',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      8.0.width,
                      InkWell(
                        onTap: () {
                          ref.read(balanceVisibleController.notifier).toggle();
                        },
                        child: Icon(
                          size: 18,
                          SharedPrefManager.balanceVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.grey300,
                        ),
                      )
                    ],
                  ),
                  12.0.height,

                  // Wallet Balance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (ref.watch(fetchWalletDetailsProvider).isLoading) ...[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                        8.0.width,
                      ],
                      Text(
                        ref.watch(balanceVisibleController)
                            ? walletDetails.hasValue
                                ? walletDetails.value?.availableBalance
                                        .amountWithCurrency(userData.primaryCurrency ?? '') ??
                                    '0'
                                : 0.amountWithCurrency(userData.primaryCurrency ?? '')
                            : '●●●●●●●●●●',
                        style: context.textTheme.displaySmall?.copyWith(
                          fontSize: ref.watch(balanceVisibleController) ? 29 : 20,
                          color: AppColors.black2,
                          fontFamily: FontFamily.inter,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  8.0.height,

                  // Pending Balance
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.highlightYellow50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: AppColors.highlightYellow,
                          size: 16,
                        ),
                        4.0.width,
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Pending Balance: ',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: AppColors.highlightYellow,
                                  fontFamily: FontFamily.inter,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: ref.watch(balanceVisibleController)
                                    ? walletDetails.hasValue
                                        ? walletDetails.value?.pendingBalance.amountWithCurrency(
                                                userData.primaryCurrency ?? '') ??
                                            '0'
                                        : 0.amountWithCurrency(userData.primaryCurrency ?? '')
                                    : '●●●●●',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: AppColors.subHeading,
                                  fontFamily: FontFamily.inter,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.0.height,

                  // Fund or Withdraw Buttons
                  GuardedShowcase(
                    showcaseKey: TourKeys.walletPayout,
                    description: 'Withdraw earnings or fund your wallet for bookings.',
                    targetBorderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        children: [
                          Expanded(
                            child: MainButton(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              color: AppColors.btnTertiary,
                              text: 'Withdraw',
                              textColor: AppColors.btnText,
                              onPressed: () {
                                if (ref.watch(fetchWalletDetailsProvider).value?.hasPin == false) {
                                  AppBottomSheet.showBottomSheet(
                                    context,
                                    widget: const SetWithdrawalPinSheet(),
                                  );
                                  return;
                                }

                                AppBottomSheet.showBottomSheet(
                                  context,
                                  widget: const WithdrawalSheet(),
                                );
                              },
                            ),
                          ),
                          12.0.width,
                          Expanded(
                            child: MainButton(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              text: 'Fund Wallet',
                              onPressed: () {
                                AppBottomSheet.showBottomSheet(
                                  context,
                                  widget: const FundWalletSheet(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  18.0.height,
                ],
              ),
            ),

            // MARK: Transaction List
            Expanded(
              child: RefreshIndicator.adaptive(
                backgroundColor: Colors.white,
                color: AppColors.primary,
                onRefresh: () async {
                  ref.invalidate(fetchWalletDetailsProvider);
                  ref.invalidate(getTransactionsProvider);
                },
                child: transactions.when(
                  data: (data) {
                    return CustomScrollView(
                      slivers: [
                        // MARK: Incoming & Outgoing Cards
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: IncomingOutcomingCard(
                                    amount: (data.summary?.totalIncoming ?? 0)
                                        .amountWithCurrency(userData.primaryCurrency ?? ''),
                                  )
                                      .animate()
                                      .fadeIn(delay: 100.ms, duration: 300.ms)
                                      .slideX(begin: -.1),
                                ),
                                12.0.width,
                                Expanded(
                                  child: IncomingOutcomingCard(
                                    title: 'Outgoing',
                                    amount: (data.summary?.totalOutgoing ?? 0)
                                        .amountWithCurrency(userData.primaryCurrency ?? ''),
                                    iconColor: AppColors.highlightRed,
                                  )
                                      .animate()
                                      .fadeIn(delay: 100.ms, duration: 300.ms)
                                      .slideX(begin: .1),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(child: 12.0.height),

                        // MARK: Transactions
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Transactions',
                                  style: context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    context.push(const AllTransactionsView());
                                  },
                                  child: Text(
                                    'View all',
                                    style: context.textTheme.bodySmall?.copyWith(
                                      color: AppColors.highlightCoral,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(child: 8.0.height),

                        // Transaction List
                        if (data.data?.isEmpty == true)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Column(
                              children: [
                                48.0.height,
                                SvgPicture.asset(AppImages.transactionsIllustration),
                                24.0.height,
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'No transactions yet. Your incoming and outgoing payments will appear here',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.body,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final transaction = data.data![index];
                                return TransactionItem(
                                  transaction: transaction,
                                );
                              },
                              childCount:
                                  (data.data?.length ?? 0) <= 5 ? (data.data?.length ?? 0) : 5,
                            ),
                          ),

                        SliverToBoxAdapter(child: 24.0.height),
                      ],
                    );
                  },
                  error: (error, stacktrace) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        Text('Error: ${error.toString()}'),
                        12.0.height,
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                ref.invalidate(getTransactionsProvider);
                              },
                              child: Text(
                                'Refresh',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.highlightRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (ref.watch(getTransactionsProvider).isLoading) ...[
                              8.0.width,
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                                ),
                              ),
                            ],
                          ],
                        )
                      ],
                    ),
                  ),
                  loading: () => const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                        SizedBox(height: 8),
                        Text('Fetching Transaction Info'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
