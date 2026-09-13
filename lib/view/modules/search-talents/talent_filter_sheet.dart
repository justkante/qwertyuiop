import 'package:creatify_mobile/data/models/responses/creator_availabiity_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/states_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/filter_creators_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

ValueNotifier<StatesItemDto?> locationNotifier = ValueNotifier<StatesItemDto?>(null);
ValueNotifier<double> minPriceNotifier = ValueNotifier<double>(1);
ValueNotifier<double> maxPriceNotifier = ValueNotifier<double>(10000000);
ValueNotifier<Set<String>> categoriesNotifier = ValueNotifier<Set<String>>({});

class TalentFilterSheet extends ConsumerStatefulWidget {
  const TalentFilterSheet({
    super.key,
  });

  @override
  ConsumerState<TalentFilterSheet> createState() => _TalentFilterSheetState();
}

class _TalentFilterSheetState extends ConsumerState<TalentFilterSheet> {
  // Filter state variables
  Set<String> selectedCategories = {};
  RangeValues amountRange = const RangeValues(1000, 10000000);
  RangeValues internationalAmountRange = const RangeValues(1, 10000000);
  static const double minAmount = 1000;
  static const double minInternationalAmount = 1;
  static const double maxAmount = 10000000;
  final TextEditingController locationController = TextEditingController();

  // Track which top-level category is expanded
  String? expandedCategoryId;

  // Track whether to show all parent categories
  bool showAllParentCategories = false;

  StatesItemDto? selectedState;

  @override
  void initState() {
    super.initState();
    // Initialize location if previously selected
    setState(() {
      selectedCategories = categoriesNotifier.value;
      amountRange = RangeValues(minPriceNotifier.value, maxPriceNotifier.value);
      locationController.text = locationNotifier.value?.name ?? '';
    });
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Icons.close,
                          color: Colors.transparent,
                          size: 24,
                        ),
                      ),
                      Text(
                        'Filter Search',
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black2,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.body,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  8.0.height,
                  Center(
                    child: Text(
                      'Refine your results to find the perfect match',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.body,
                      ),
                    ),
                  ),
                  32.0.height,

                  // By Categories
                  _buildFilterSection(
                    title: 'By Categories',
                    child: _buildCategoryFilter(),
                  ),
                  24.0.height,

                  // By Rate
                  _buildFilterSection(
                    title: 'By Rate',
                    child: _buildAmountFilter(),
                  ),
                  24.0.height,

                  // By Location
                  _buildFilterSection(
                    title: 'By Location',
                    child: _buildLocationFilter(),
                  ),
                  32.0.height,
                ],
              ),
            ),
          ),
          12.0.height,
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
          12.0.height,
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
        8.0.height,
        child,
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final asyncValue = ref.watch(fetchGroupedCreatorNichesProvider);

    if (asyncValue.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Loading Categories...'),
            8.0.height,
            const CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ],
        ),
      );
    }

    if (asyncValue.hasError) {
      return Center(child: Text(asyncValue.error.toString()));
    }

    final nicheGroups = asyncValue.value ?? [];
    final visibleGroups = showAllParentCategories ? nicheGroups : nicheGroups.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...visibleGroups.map((niche) {
          final isExpanded = expandedCategoryId == niche.id;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    expandedCategoryId = isExpanded ? null : niche.id;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          niche.name ?? '',
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: AppColors.btnText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppColors.btnText,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded && (niche.categories?.isNotEmpty ?? false)) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (niche.categories ?? []).map((sub) {
                    final isSelected = selectedCategories.contains(sub.name);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedCategories.remove(sub.name);
                          } else {
                            selectedCategories.add(sub.name ?? '');
                          }
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
                          sub.name ?? '',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: isSelected ? Colors.white : AppColors.subHeading,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                8.0.height,
              ],
              // Divider(color: AppColors.grey300, height: 1),
            ],
          );
        }),
        if (nicheGroups.length > 5) ...[
          12.0.height,
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showAllParentCategories = !showAllParentCategories;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    showAllParentCategories ? 'Show Less' : 'Show More',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.highlightCoral,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  4.0.width,
                  Icon(
                    showAllParentCategories ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.highlightCoral,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAmountFilter() {
    final userData = ref.watch(userControllerProvider);

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
                  userData.primaryCurrency != 'ngn'
                      ? internationalAmountRange.start
                          .amountWithCurrency(userData.primaryCurrency ?? '')
                      : amountRange.start.amountWithCurrency(userData.primaryCurrency ?? ''),
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
                  userData.primaryCurrency != 'ngn'
                      ? internationalAmountRange.end
                          .amountWithCurrency(userData.primaryCurrency ?? '')
                      : amountRange.end.amountWithCurrency(userData.primaryCurrency ?? ''),
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
            min: userData.primaryCurrency != 'ngn' ? minInternationalAmount : minAmount,
            max: maxAmount,
            values: userData.primaryCurrency != 'ngn' ? internationalAmountRange : amountRange,
            divisions: 100,
            labels: RangeLabels(
              userData.primaryCurrency != 'ngn'
                  ? internationalAmountRange.start
                      .amountWithCurrency(userData.primaryCurrency ?? '')
                  : amountRange.start.amountWithCurrency(userData.primaryCurrency ?? ''),
              userData.primaryCurrency != 'ngn'
                  ? internationalAmountRange.end.amountWithCurrency(userData.primaryCurrency ?? '')
                  : amountRange.end.amountWithCurrency(userData.primaryCurrency ?? ''),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                if (userData.primaryCurrency != 'ngn') {
                  internationalAmountRange = values;
                } else {
                  amountRange = values;
                }
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
              userData.primaryCurrency == 'ngn'
                  ? minAmount.amountWithCurrency(userData.primaryCurrency ?? '')
                  : minInternationalAmount.amountWithCurrency(userData.primaryCurrency ?? ''),
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.body,
                fontSize: 10,
                fontFamily: FontFamily.inter,
              ),
            ),
            Text(
              maxAmount.amountWithCurrency(userData.primaryCurrency ?? ''),
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

  Widget _buildLocationFilter() {
    return TextInputField(
      controller: locationController,
      hint: 'Select Location',
      readOnly: true,
      inputType: TextInputType.number,
      onPressed: () async {
        selectedState = await AppBottomSheet.showBottomSheet(
          context,
          widget: const StateSheet(),
        );

        if (selectedState != null) {
          locationController.text = selectedState?.name ?? '';
        }
      },
      suffixIcon: const Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.body,
        size: 18,
      ),
      validator: null,
    );
  }

  void _clearFilters() {
    // Clear filters in the provider
    ref.read(hasSearchFiltersProvider.notifier).state = false;

    ref.read(filterCreatorsProvider.notifier).filterCreators();

    final userData = ref.read(userControllerProvider);
    final isInternational = userData.primaryCurrency != 'ngn';

    setState(() {
      selectedCategories.clear();
      amountRange = const RangeValues(minAmount, maxAmount);
      internationalAmountRange = const RangeValues(minInternationalAmount, maxAmount);
      locationController.clear();

      // Collapse any expanded category and reset show more
      expandedCategoryId = null;
      showAllParentCategories = false;

      // Reset Values
      locationNotifier.value = StatesItemDto();
      minPriceNotifier.value = isInternational ? minInternationalAmount : minAmount;
      maxPriceNotifier.value = maxAmount;
      categoriesNotifier.value = {};
    });
  }

  void _applyFilters() {
    final userData = ref.read(userControllerProvider);
    final isInternational = userData.primaryCurrency != 'ngn';
    final currentRange = isInternational ? internationalAmountRange : amountRange;
    final currentMin = isInternational ? minInternationalAmount : minAmount;

    // Check if the filters are null
    if (selectedState == null &&
        currentRange.start == currentMin &&
        currentRange.end == maxAmount &&
        selectedCategories.isEmpty) {
      // No filters selected, do nothing
      context.pop();
    } else {
      // Set that filters are applied
      ref.read(hasSearchFiltersProvider.notifier).state = true;

      ref.read(filterCreatorsProvider.notifier).filterCreators(
            location: selectedState?.id,
            priceMin: currentRange.start == currentMin ? null : currentRange.start,
            priceMax: currentRange.end == maxAmount ? null : currentRange.end,
            category: selectedCategories
                .map((e) => e.removeSpace().removeSlash().toLowerCase())
                .join('|'),
          );

      setState(() {
        // Set the Values
        locationNotifier.value = selectedState;
        minPriceNotifier.value = currentRange.start;
        maxPriceNotifier.value = currentRange.end;
        categoriesNotifier.value = selectedCategories;
      });

      context.pop(true);
    }
  }
}
