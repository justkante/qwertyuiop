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
ValueNotifier<String?> workModeNotifier = ValueNotifier<String?>(null);

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
  String? selectedWorkMode;

  // Track expanded sections
  bool isCategoriesExpanded = true;
  bool isRateExpanded = true;
  bool isLocationExpanded = true;
  bool isRatingExpanded = true;
  bool isAvailabilityExpanded = true;
  bool isWorkModeExpanded = true;

  // Track which top-level category is expanded
  String? expandedCategoryId;

  // Track whether to show all parent categories
  bool showAllParentCategories = false;

  StatesItemDto? selectedState;

  @override
  void initState() {
    super.initState();
    final initialCategories = categoriesNotifier.value;
    setState(() {
      selectedCategories = initialCategories;
      amountRange = RangeValues(
        minPriceNotifier.value.clamp(minAmount, maxAmount),
        maxPriceNotifier.value.clamp(minAmount, maxAmount),
      );
      locationController.text = locationNotifier.value?.name ?? '';
      selectedWorkMode = workModeNotifier.value;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoriesAsync = ref.read(fetchGroupedCreatorNichesProvider);
      categoriesAsync.whenData((groups) {
        final selectedNormalized = initialCategories.map((e) => e.toLowerCase().trim()).toSet();
        for (final group in groups) {
          final childNames = (group.categories ?? []).map((c) => (c.name ?? '').toLowerCase().trim()).toSet();
          if (selectedNormalized.contains((group.name ?? '').toLowerCase().trim()) ||
              childNames.any((child) => selectedNormalized.contains(child))) {
            if (mounted) {
              setState(() {
                expandedCategoryId = group.id;
              });
            }
            break;
          }
        }
      });
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
                        onTap: () => Navigator.of(context).pop(),
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
                        onTap: () => Navigator.of(context).pop(),
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
                  24.0.height,

                  // By Work Mode Dropdown
                  _buildFilterSection(
                    title: 'By Work Mode',
                    isExpanded: isWorkModeExpanded,
                    onToggle: () => setState(() => isWorkModeExpanded = !isWorkModeExpanded),
                    child: _buildWorkModeFilter(),
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

  Widget _buildWorkModeFilter() {
    final workModes = ['Hybrid', 'Remote', 'On-site'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: workModes.map((mode) {
        final isSelected = selectedWorkMode == mode;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedWorkMode = isSelected ? null : mode;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE0F2F1) : AppColors.grey50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.grey200,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              mode,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : const Color(0xFF1B3131),
              ),
            ),
          ),
        );
      }).toList(),
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

    final validRating = (selectedRating != null && ratings.any((r) => r['val'] == selectedRating)) ? selectedRating : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: DropdownButtonFormField<double>(
        value: validRating,
        isExpanded: true,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1B3131), fontWeight: FontWeight.w400),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: Icon(Icons.keyboard_arrow_down, color: AppColors.body, size: 20),
        ),
        icon: const SizedBox.shrink(),
        hint: const Text(
          'Select rating',
          style: TextStyle(color: AppColors.body, fontSize: 13, fontWeight: FontWeight.w400),
        ),
        items: ratings.map((r) {
          return DropdownMenuItem<double>(
            value: r['val'] as double,
            child: Text(
              r['label'] as String,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1B3131), fontWeight: FontWeight.w400),
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
    final availabilities = ['Available now'];
    final validAvail = (selectedAvailability != null && availabilities.contains(selectedAvailability)) ? selectedAvailability : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: DropdownButtonFormField<String>(
        value: validAvail,
        isExpanded: true,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1B3131), fontWeight: FontWeight.w400),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: Icon(Icons.keyboard_arrow_down, color: AppColors.body, size: 20),
        ),
        icon: const SizedBox.shrink(),
        hint: const Text(
          'Select availability',
          style: TextStyle(color: AppColors.body, fontSize: 13, fontWeight: FontWeight.w400),
        ),
        items: availabilities.map((a) {
          return DropdownMenuItem<String>(
            value: a,
            child: Text(
              a,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1B3131), fontWeight: FontWeight.w400),
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

  Widget _buildAmountFilter() {
    final userData = ref.watch(userControllerProvider);
    final isInternational = userData.primaryCurrency != 'ngn';
    final currentRange = _getSafeAmountRange(isInternational);
    final minVal = isInternational ? minInternationalAmount : minAmount;
    final maxVal = maxAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currentRange.start.amountWithCurrency(userData.primaryCurrency ?? ''),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.heading),
            ),
            Text(
              currentRange.end.amountWithCurrency(userData.primaryCurrency ?? ''),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.heading),
            ),
          ],
        ),
        RangeSlider(
          values: currentRange,
          min: minVal,
          max: maxVal,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.grey200,
          onChanged: (values) {
            setState(() {
              if (isInternational) {
                internationalAmountRange = values;
              } else {
                amountRange = values;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildLocationFilter() {
    return GestureDetector(
      onTap: () async {
        final result = await AppBottomSheet.showBottomSheet(
          context,
          widget: const StateSheet(),
        );
        if (result is StatesItemDto) {
          setState(() {
            selectedState = result;
            locationController.text = result.name ?? '';
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.body, size: 18),
            8.0.width,
            Expanded(
              child: Text(
                locationController.text.isEmpty ? 'Select location' : locationController.text,
                style: TextStyle(
                  fontSize: 13,
                  color: locationController.text.isEmpty ? AppColors.body : const Color(0xFF1B3131),
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.body, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categoriesAsync = ref.watch(fetchGroupedCreatorNichesProvider);

    return categoriesAsync.when(
      data: (groups) {
        if (groups.isEmpty) {
          return const Text('No categories available', style: TextStyle(fontSize: 12, color: AppColors.body));
        }

        final parentCategories = showAllParentCategories ? groups : groups.take(6).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: parentCategories.map((group) {
                final catName = group.name ?? '';
                final normalizedCatName = catName.toLowerCase().trim();
                final childNames = (group.categories ?? []).map((c) => c.name ?? '').toSet();
                final childNamesNormalized = childNames.map((c) => c.toLowerCase().trim()).toSet();
                final selectedNormalized = selectedCategories.map((e) => e.toLowerCase().trim()).toSet();

                final isSelected = selectedNormalized.contains(normalizedCatName) ||
                    childNamesNormalized.any((child) => selectedNormalized.contains(child));

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedCategories.removeWhere((e) =>
                            e.toLowerCase().trim() == normalizedCatName ||
                            childNamesNormalized.contains(e.toLowerCase().trim()));
                        expandedCategoryId = null;
                      } else {
                        selectedCategories.add(catName);
                        expandedCategoryId = group.id;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE0F2F1) : AppColors.grey50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.grey200,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      catName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.primary : const Color(0xFF1B3131),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (groups.length > 6) ...[
              12.0.height,
              GestureDetector(
                onTap: () {
                  setState(() {
                    showAllParentCategories = !showAllParentCategories;
                  });
                },
                child: Text(
                  showAllParentCategories ? 'Show less' : 'View more (${groups.length - 6} more)',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            if (expandedCategoryId != null) ...[
              16.0.height,
              const Text(
                'Sub-niches / Services',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.heading),
              ),
              8.0.height,
              Builder(
                builder: (context) {
                  final group = groups.firstWhere(
                    (g) => g.id == expandedCategoryId,
                    orElse: () => groups.first,
                  );
                  final niches = group.categories ?? [];
                  return Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: niches.map((niche) {
                      final nicheName = niche.name ?? '';
                      final isSelected = selectedCategories.contains(nicheName);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedCategories.remove(nicheName);
                            } else {
                              selectedCategories.add(nicheName);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFE0F2F1) : AppColors.grey100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                            ),
                          ),
                        child: Text(
                            nicheName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                              color: isSelected ? AppColors.primary : AppColors.subHeading,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, __) => const Text('Error loading categories', style: TextStyle(fontSize: 12, color: AppColors.body)),
    );
  }

  void _clearFilters() {
    ref.read(hasSearchFiltersProvider.notifier).state = false;
    ref.read(filterCreatorsProvider.notifier).filterCreators();

    final userData = ref.watch(userControllerProvider);
    final isInternational = userData.primaryCurrency != 'ngn';

    setState(() {
      selectedCategories.clear();
      amountRange = const RangeValues(minAmount, maxAmount);
      internationalAmountRange = const RangeValues(minInternationalAmount, maxAmount);
      locationController.text = '';
      selectedRating = null;
      selectedAvailability = null;
      selectedWorkMode = null;

      expandedCategoryId = null;
      showAllParentCategories = false;

      locationNotifier.value = null;
      minPriceNotifier.value = isInternational ? minInternationalAmount : minAmount;
      maxPriceNotifier.value = maxAmount;
      categoriesNotifier.value = {};
      workModeNotifier.value = null;
    });
  }

  void _applyFilters() {
    final userData = ref.read(userControllerProvider);
    final isInternational = userData.primaryCurrency != 'ngn';
    final currentRange = _getSafeAmountRange(isInternational);
    final currentMin = isInternational ? minInternationalAmount : minAmount;

    if (selectedState == null &&
        locationController.text.isEmpty &&
        currentRange.start == currentMin &&
        currentRange.end == maxAmount &&
        selectedCategories.isEmpty &&
        selectedRating == null &&
        selectedAvailability == null &&
        selectedWorkMode == null) {
      Navigator.of(context).pop();
    } else {
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
            workMode: selectedWorkMode,
          );

      setState(() {
        locationNotifier.value = selectedState;
        minPriceNotifier.value = currentRange.start;
        maxPriceNotifier.value = currentRange.end;
        categoriesNotifier.value = selectedCategories;
        workModeNotifier.value = selectedWorkMode;
      });

      Navigator.of(context).pop(true);
    }
  }
}
