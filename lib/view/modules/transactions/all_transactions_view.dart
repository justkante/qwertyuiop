import 'package:creatify_mobile/view/modules/onboarding/widgets/search_input_field.dart';
import 'package:creatify_mobile/view/modules/transactions/transaction_filter_sheet.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/get_transactions_vm.dart';
import 'package:creatify_mobile/view/modules/transactions/widgets/transaction_item.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/linear_loading.dart';
import 'package:creatify_mobile/view/widgets/quick_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AllTransactionsView extends ConsumerStatefulWidget {
  const AllTransactionsView({super.key});

  @override
  ConsumerState<AllTransactionsView> createState() => _AllTransactionsViewState();
}

class _AllTransactionsViewState extends ConsumerState<AllTransactionsView> {
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
    final transactions = ref.watch(getTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Transactions',
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.subHeading,
          ),
        ),
      ),
      body: Column(
        children: [
          12.0.height,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SearchTextInputField(
                    hintText: 'Search Name, Amount...',
                    controller: searchController,
                  ),
                ),
                12.0.width,
                Stack(
                  children: [
                    QuickIcon(
                      onTap: () async {
                        final result = await AppBottomSheet.showBottomSheet(
                          context,
                          widget: TransactionFilterSheet(
                            initialFilters: appliedFilters,
                          ),
                        );

                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            appliedFilters = result;
                          });
                        }
                      },
                      icon: AppImages.filter,
                      size: 18,
                      padding: 10,
                      borderColor: AppColors.icons,
                      color: (appliedFilters != null && _hasActiveFilters())
                          ? Colors.white
                          : AppColors.icons,
                      bgColor: (appliedFilters != null && _hasActiveFilters())
                          ? AppColors.primary
                          : Colors.white,
                    ),
                    if (appliedFilters != null && _hasActiveFilters())
                      Positioned(
                        right: 3,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.highlightCoral,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          12.0.height,
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () async {
                ref.invalidate(getTransactionsProvider);
              },
              child: transactions.when(
                data: (data) {
                  final filteredTransactions = data.data?.where((transaction) {
                    final matchesSearch =
                        transaction.otherParty?.name?.toLowerCase().contains(searchQuery);
                    final matchesType = transaction.type
                        ?.toLowerCase()
                        .contains(searchQuery.toLowerCase().addUnderscore());
                    final matchesAmount = transaction.amount.toString().contains(searchQuery);
                    // Additional filter logic can be added here based on appliedFilters
                    return matchesSearch == true || matchesType == true || matchesAmount == true;
                  }).toList();

                  return CustomScrollView(
                    slivers: [
                      if (ref.watch(getTransactionsProvider).isLoading) ...[
                        SliverToBoxAdapter(child: 12.0.height),
                        const SliverToBoxAdapter(child: LineLoadingIndicator(loading: true)),
                      ],

                      // Show active filters if any
                      if (appliedFilters != null && _hasActiveFilters()) ...[
                        SliverToBoxAdapter(child: 12.0.height),
                        SliverToBoxAdapter(child: _buildActiveFilters()),
                        SliverToBoxAdapter(child: .0.height),
                      ],

                      // Transaction List
                      if (filteredTransactions?.isEmpty == true)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            children: [
                              48.0.height,
                              SvgPicture.asset(AppImages.transactionsIllustration),
                              24.0.height,
                              Text(
                                'No transactions yet. Your incoming and outgoing payments will appear here',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.body,
                                    ),
                              ),
                            ],
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final transaction = filteredTransactions![index];
                              return TransactionItem(
                                transaction: transaction,
                              );
                            },
                            childCount: filteredTransactions?.length ?? 0,
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
    );
  }

  bool _hasActiveFilters() {
    if (appliedFilters == null) return false;

    // Check if amount range has been modified from default values
    bool hasAmountFilter = false;
    if (appliedFilters!['minAmount'] != null && appliedFilters!['maxAmount'] != null) {
      final minAmount = int.tryParse(appliedFilters!['minAmount']) ?? 10000;
      final maxAmount = int.tryParse(appliedFilters!['maxAmount']) ?? 5000000;
      hasAmountFilter = minAmount != 10000 || maxAmount != 5000000;
    }

    return (appliedFilters!['category'] != 'All Transactions') ||
        (appliedFilters!['status'] != 'All') ||
        hasAmountFilter ||
        (appliedFilters!['startDate'] != null) ||
        (appliedFilters!['endDate'] != null);
  }

  Widget _buildActiveFilters() {
    List<String> activeFilters = [];

    if (appliedFilters!['category'].toString().isNotEmpty) {
      activeFilters.add(appliedFilters!['category']);
    }

    if (appliedFilters!['status'].toString().isNotEmpty) {
      activeFilters.add(appliedFilters!['status']);
    }

    // Check if amount range has been modified from default values
    if (appliedFilters!['minAmount'].toString() == '10000' &&
        appliedFilters!['maxAmount'].toString() == '5000000') {
      final minAmount = int.tryParse(appliedFilters!['minAmount']) ?? 10000;
      final maxAmount = int.tryParse(appliedFilters!['maxAmount']) ?? 5000000;
      if (minAmount != 10000 || maxAmount != 5000000) {
        activeFilters.add('₦${_formatAmount(minAmount)} - ₦${_formatAmount(maxAmount)}');
      }
    }

    if (appliedFilters!['startDate'] != null || appliedFilters!['endDate'] != null) {
      activeFilters.add('Date Range');
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt,
            size: 16,
            color: AppColors.primary,
          ),
          8.0.width,
          Expanded(
            child: Text(
              'Active filters: ${activeFilters.join(', ')}',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.subHeading,
                fontFamily: FontFamily.inter,
                fontSize: 12,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                appliedFilters = null;
              });
              ref.invalidate(getTransactionsProvider);
            },
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.body,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}K';
    } else {
      return amount.toString();
    }
  }
}
