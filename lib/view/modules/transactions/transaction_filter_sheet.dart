import 'package:creatify_mobile/view/modules/transactions/vm/get_transactions_vm.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_date_picker.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TransactionFilterSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialFilters;
  const TransactionFilterSheet({super.key, this.initialFilters});

  @override
  ConsumerState<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends ConsumerState<TransactionFilterSheet> {
  // Filter state variables
  String selectedCategory = '';
  String selectedStatus = '';
  RangeValues amountRange = const RangeValues(1000, 5000000);
  static const double minAmount = 1000;
  static const double maxAmount = 5000000;
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  String? startDate;
  String? endDate;

  @override
  void initState() {
    super.initState();
    // Initialize filters from initialFilters if provided
    if (widget.initialFilters != null) {
      selectedCategory = widget.initialFilters!['category'] ?? '';
      selectedStatus = widget.initialFilters!['status'] ?? '';
      final minAmt = widget.initialFilters!['minAmount'];
      final maxAmt = widget.initialFilters!['maxAmount'];
      if (minAmt != null && maxAmt != null) {
        amountRange = RangeValues(double.parse(minAmt), double.parse(maxAmt));
      }
    }
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Transactions',
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.body,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                48.0.height,

                // By Categories
                _buildFilterSection(
                  title: 'By Categories',
                  child: _buildCategoryFilter(),
                ),
                24.0.height,

                // By Status
                _buildFilterSection(
                  title: 'By Status',
                  child: _buildStatusFilter(),
                ),
                24.0.height,

                // By Amount
                _buildFilterSection(
                  title: 'By Amount',
                  child: _buildAmountFilter(),
                ),
                24.0.height,

                // By Date
                _buildFilterSection(
                  title: 'By Date',
                  child: _buildDateFilter(),
                ),
                32.0.height,
              ],
            ),
          ),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: MainButton(
                  text: 'Clear Filter',
                  color: AppColors.grey200,
                  textColor: AppColors.heading,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onPressed: _clearFilters,
                ),
              ),
              16.0.width,
              Expanded(
                child: MainButton(
                  text: 'Apply Filter',
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onPressed: _applyFilters,
                ),
              ),
            ],
          ),
          24.0.height,
        ],
      ),
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.bodyLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.subHeading,
          ),
        ),
        12.0.height,
        child,
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Incoming', 'Outgoing'];

    return Wrap(
      spacing: 8,
      children: categories.map((category) {
        final isSelected = selectedCategory == category;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategory = category;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.highlightCoral : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.highlightCoral : AppColors.grey300,
              ),
            ),
            child: Text(
              category,
              style: context.textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white : AppColors.subHeading,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = ['Pending', 'Failed', 'Successful'];

    return Wrap(
      spacing: 8,
      children: statuses.map((status) {
        final isSelected = selectedStatus == status;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedStatus = status;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.highlightCoral : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.highlightCoral : AppColors.grey300,
              ),
            ),
            child: Text(
              status,
              style: context.textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white : AppColors.subHeading,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amount range display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minimum',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.body,
                    fontSize: 12,
                  ),
                ),
                4.0.height,
                Text(
                  '₦${amountRange.start.round().toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      )}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading,
                    fontFamily: FontFamily.inter,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Maximum',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.body,
                    fontSize: 12,
                  ),
                ),
                4.0.height,
                Text(
                  '₦${amountRange.end.round().toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      )}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading,
                    fontFamily: FontFamily.inter,
                  ),
                ),
              ],
            ),
          ],
        ),
        8.0.height,

        // Range Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.spot500,
            inactiveTrackColor: AppColors.grey300,
            thumbColor: AppColors.highlightCoral,
            overlayColor: AppColors.highlightCoral.withValues(alpha: 0.1),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
            rangeValueIndicatorShape: const RectangularRangeSliderValueIndicatorShape(),
            showValueIndicator: ShowValueIndicator.onlyForDiscrete,
            valueIndicatorTextStyle: context.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontFamily: FontFamily.inter,
            ),
          ),
          child: RangeSlider(
            min: minAmount,
            max: maxAmount,
            values: amountRange,
            divisions: 100,
            labels: RangeLabels(
              '₦${amountRange.start.round().toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  )}',
              '₦${amountRange.end.round().toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  )}',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                amountRange = values;
              });
            },
          ),
        ),
        8.0.height,

        // Range indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₦1K',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.body,
                fontSize: 10,
                fontFamily: FontFamily.inter,
              ),
            ),
            Text(
              '₦5M',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.body,
                fontSize: 10,
                fontFamily: FontFamily.inter,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateFilter() {
    return Row(
      children: [
        Expanded(
          child: TextInputField(
            controller: startDateController,
            hint: 'Start Date',
            readOnly: true,
            inputType: TextInputType.number,
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.body,
              size: 18,
            ),
            onPressed: () async {
              final date = await showPlatformDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2025),
                lastDate: DateTime.now(),
              );

              // Format the Date like this 'YYYY-MM-DD' and set to controller
              if (date != null) {
                final formattedDate =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                setState(() {
                  startDate = formattedDate;
                  startDateController.text = formattedDate;
                });
              }
            },
            validator: null,
          ),
        ),
        16.0.width,
        Expanded(
          child: TextInputField(
            controller: endDateController,
            hint: 'End Date',
            readOnly: true,
            inputType: TextInputType.number,
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.body,
              size: 18,
            ),
            onPressed: () async {
              final date = await showPlatformDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2025),
                lastDate: DateTime.now(),
              );

              if (date != null) {
                final formattedDate =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                setState(() {
                  endDate = formattedDate;
                  endDateController.text = formattedDate;
                });
              }
            },
            validator: null,
          ),
        ),
      ],
    );
  }

  void _clearFilters() {
    ref.invalidate(getTransactionsProvider);

    setState(() {
      selectedCategory = '';
      selectedStatus = '';
      amountRange = const RangeValues(minAmount, maxAmount);
      startDate = null;
      endDate = null;
      startDateController.clear();
      endDateController.clear();
    });
  }

  void _applyFilters() {
    // Handle case where no filters are selected
    if (selectedCategory.isEmpty &&
        selectedStatus.isEmpty &&
        amountRange.start == minAmount &&
        amountRange.end == maxAmount &&
        startDate == null &&
        endDate == null) {
      Navigator.of(context).pop();
      return;
    }

    // Apply filters logic here
    ref.read(getTransactionsProvider.notifier).getTransactions(
          category: selectedCategory.toLowerCase(),
          status: selectedStatus.toLowerCase(),
          minAmount: minAmount.round().toString() == amountRange.start.round().toString()
              ? null
              : amountRange.start.round().toString(),
          maxAmount: maxAmount.round().toString() == amountRange.end.round().toString()
              ? null
              : amountRange.end.round().toString(),
          startDate: startDate,
          endDate: endDate,
        );

    // You can pass the filter data back to the parent widget
    Navigator.of(context).pop({
      'category': selectedCategory,
      'status': selectedStatus,
      'minAmount': amountRange.start.round().toString(),
      'maxAmount': amountRange.end.round().toString(),
      'startDate': startDate,
      'endDate': endDate,
    });
  }
}
