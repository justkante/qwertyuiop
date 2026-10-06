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

  double? selectedRating;
  String? selectedAvailability;

  // Track expanded sections
  bool isCategoriesExpanded = true;
  bool isRateExpanded = true;
  bool isLocationExpanded = true;
  bool isRatingExpanded = true;
  bool isAvailabilityExpanded = true;

  // Track which top-level category is expanded
  String? expandedCategoryId;

  // Track whether to show all parent categories
  bool showAllParentCategories = false;

  StatesItemDto? selectedState;

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedCategories = categoriesNotifier.value;
      amountRange = RangeValues(
        minPriceNotifier.value.clamp(minAmount, maxAmount),
        maxPriceNotifier.value.clamp(minAmount, maxAmount),
      );
      locationController.text = locationNotifier.value?.name ?? '';
    });
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  RangeValues _getSafeAmountRange(bool isInternational) {
    final minVal = isInternational ? minInternationalAmount : minAmount;
    final maxVal = maxAmount;
    final current = isInternational ? internationalAmountRange : amountRange;

    double start = current.start;
    double end = current.end;

    if (start < minVal) start = minVal;
    if (start > maxVal) start = maxVal;
    if (end < start) end = start;
    if (end > maxVal) end = maxVal;

    return RangeValues(start, end);
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

                  // By Categories Dropdown
                  _buildFilterSection(
                    title: 'By Categories',
                    isExpanded: isCategoriesExpanded,
                    onToggle: () => setState(() => isCategoriesExpanded = !isCategoriesExpanded),
                    child: _buildCategoryFilter(),
                  ),
                  24.0.height,

                  // By Rate Dropdown
                  _buildFilterSection(
                    title: 'By Rate',
                    isExpanded: isRateExpanded,
                    onToggle: () => setState(() => isRateExpanded = !isRateExpanded),
                    child: _buildAmountFilter(),
                  ),
                  24.0.height,

                  // By Location Dropdown
                  _buildFilterSection(
                    title: 'By Location',
                    isExpanded: isLocationExpanded,
                    onToggle: () => setState(() => isLocationExpanded = !isLocationExpanded),
                    child: _buildLocationFilter(),
                  ),
                  24.0.height,

                  // By Rating Dropdown
                  _buildFilterSection(
                    title: 'By Rating',
                    isExpanded: isRatingExpanded,
                    onToggle: () => setState(() => isRatingExpanded = !isRatingExpanded),
                    child: _buildRatingFilter(),
                  ),
                  24.0.height,

                  // By Availability Dropdown
                  _buildFilterSection(
                    title: 'By Availability',
                    isExpanded: isAvailabilityExpanded,
                    onToggle: () => setState(() => isAvailabilityExpanded = !isAvailabilityExpanded),
                    child: _buildAvailabilityFilter(),
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

  Widget _buildFilterSection({
    required String title,
    required Widget child,
    bool isExpanded = true,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            title,
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B3131),
            ),
          ),
        ),
        8.0.height,
        child,
      ],
    );
  }

  Widget _buildRatingFilter() {
    final ratings = [
      {'label': 'Any rating', 'val': 0.0},
      {'label': '4.5 & above', 'val': 4.5},
      {'label': '4.0 & above', 'val': 4.0},
      {'label': '3.5 & above', 'val': 3.5},
      {'label': 'New to Creatify', 'val': -1.0},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: DropdownButtonFormField<double>(
        value: selectedRating,
        decoration: const InputDecoration(
          hintText: 'Select rating',
          hintStyle: TextStyle(color: AppColors.body, fontSize: 13),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.body, size: 20),
        items: ratings.map((r) {
          return DropdownMenuItem<double>(
            value: r['val'] as double,
            child: Text(
              r['label'] as String,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1B3131), fontWeight: FontWeight.w500),
            ),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            selectedRating = val;
          });
        },
      ),
    );
  }

  Widget _buildAvailabilityFilter() {
    final options = ['Available now', 'Available this week', 'Available this month', 'Select dates'];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedAvailability,
        decoration: const InputDecoration(
          hintText: 'Select availability',
          hintStyle: TextStyle(color: AppColors.body, fontSize: 13),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.body, size: 20),
        items: options.map((opt) {
          return DropdownMenuItem<String>(
            value: opt,
            child: Text(
              opt,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1B3131), fontWeight: FontWeight.w500),
            ),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            selectedAvailability = val;
          });
        },
      ),
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
    final isInternational = userData.primaryCurrency != 'ngn';
    final safeRange = _getSafeAmountRange(isInternational);

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
                  safeRange.start.amountWithCurrency(userData.primaryCurrency ?? ''),
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
                  safeRange.end.amountWithCurrency(userData.primaryCurrency ?? ''),
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

        // Range Slider with safe bounds
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
            min: isInternational ? minInternationalAmount : minAmount,
            max: maxAmount,
            values: safeRange,
            divisions: 100,
            labels: RangeLabels(
              safeRange.start.amountWithCurrency(userData.primaryCurrency ?? ''),
              safeRange.end.amountWithCurrency(userData.primaryCurrency ?? ''),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                if (isInternational) {
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
              isInternational
                  ? minInternationalAmount.amountWithCurrency(userData.primaryCurrency ?? '')
                  : minAmount.amountWithCurrency(userData.primaryCurrency ?? ''),
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
    return InkWell(
      onTap: () async {
        selectedState = await AppBottomSheet.showBottomSheet(
          context,
          widget: const StateSheet(),
        );

        if (selectedState != null) {
          setState(() {
            locationController.text = selectedState?.name ?? '';
          });
        }
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                locationController.text.isEmpty ? 'Search location' : locationController.text,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1B3131),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.body, size: 22),
          ],
        ),
      ),
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
      selectedRating = null;
      selectedAvailability = null;

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
    final currentRange = _getSafeAmountRange(isInternational);
    final currentMin = isInternational ? minInternationalAmount : minAmount;

    // Check if the filters are null
    if (selectedState == null &&
        locationController.text.isEmpty &&
        currentRange.start == currentMin &&
        currentRange.end == maxAmount &&
        selectedCategories.isEmpty &&
        selectedRating == null &&
        selectedAvailability == null) {
      // No filters selected, do nothing
      context.pop();
    } else {
      // Set that filters are applied
      ref.read(hasSearchFiltersProvider.notifier).state = true;

      final locQuery = selectedState?.id ?? (locationController.text.isNotEmpty ? locationController.text : null);

      ref.read(filterCreatorsProvider.notifier).filterCreators(
            location: locQuery,
            priceMin: currentRange.start == currentMin ? null : currentRange.start,
            priceMax: currentRange.end == maxAmount ? null : currentRange.end,
            category: selectedCategories
                .map((e) => e.removeSpace().removeSlash().toLowerCase())
                .join('|'),
            rating: selectedRating,
            availability: selectedAvailability,
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
