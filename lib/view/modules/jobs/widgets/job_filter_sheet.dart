import 'package:creatify_mobile/data/models/responses/countries_dto.dart';
import 'package:creatify_mobile/view/modules/authentication/get_countries_sheet.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../showcase-talents/vm/creator_providers.dart';
import '../vm/job_controller.dart';

class JobFilterSheet extends ConsumerStatefulWidget {
  const JobFilterSheet({super.key});

  @override
  ConsumerState<JobFilterSheet> createState() => _JobFilterSheetState();
}

class _JobFilterSheetState extends ConsumerState<JobFilterSheet> {
  RangeValues _currentRangeValues = const RangeValues(1000, 50000);
  final Set<String> _selectedCategories = {};
  CountriesItemDto? _selectedCountry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 24),
              Text(
                'Filter Search',
                style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Center(
            child: Text(
              'Refine your results to find the perfect match',
              style: context.textTheme.bodySmall?.copyWith(color: AppColors.body),
            ),
          ),
          24.0.height,

          Text('By Categories', style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          12.0.height,
          ref.watch(fetchCreatorNichesProvider).when(
            data: (categories) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final isSelected = _selectedCategories.contains(cat.id);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) _selectedCategories.remove(cat.id);
                      else _selectedCategories.add(cat.id!);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF6F61) : AppColors.grey50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? const Color(0xFFFF6F61) : AppColors.grey100),
                    ),
                    child: Text(
                      cat.name ?? '',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isSelected ? Colors.white : AppColors.body,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Error loading categories', style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
          24.0.height,

          Text('By Rate (Set your budget range (₦ min -> max)', style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          RangeSlider(
            values: _currentRangeValues,
            min: 0,
            max: 100000,
            divisions: 100,
            activeColor: const Color(0xFF009688),
            inactiveColor: AppColors.grey100,
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
              });
            },
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Minimum', style: context.textTheme.bodySmall?.copyWith(fontSize: 10)),
                    4.0.height,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(10)),
                      child: Text(_currentRangeValues.start.toStringAsFixed(2), style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              16.0.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Maximum', style: context.textTheme.bodySmall?.copyWith(fontSize: 10)),
                    4.0.height,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(10)),
                      child: Text(_currentRangeValues.end.toStringAsFixed(2), style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          24.0.height,

          Text('By Country', style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          12.0.height,
          InkWell(
            onTap: () {
              AppBottomSheet.showBottomSheet(
                context,
                widget: GetCountriesSheet(
                  onCountrySelected: (country) {
                    setState(() {
                      _selectedCountry = country;
                    });
                  },
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.grey100)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_selectedCountry?.name ?? 'Select Location', style: context.textTheme.bodySmall),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.body),
                ],
              ),
            ),
          ),
          32.0.height,

          Row(
            children: [
              Expanded(
                child: MainButton(
                  text: 'Clear Filter',
                  color: const Color(0xFFACF4EE).withOpacity(0.3),
                  textColor: const Color(0xFF009688),
                  onPressed: () {
                    setState(() {
                      _currentRangeValues = const RangeValues(1000, 50000);
                      _selectedCategories.clear();
                      _selectedCountry = null;
                    });
                  },
                ),
              ),
              16.0.width,
              Expanded(
                child: MainButton(
                  text: 'Apply Filter',
                  onPressed: () {
                    ref.read(jobControllerProvider.notifier).fetchJobs(filters: {
                      if (_selectedCategories.isNotEmpty) 'category_id': _selectedCategories.first,
                      'min_price': _currentRangeValues.start,
                      'max_price': _currentRangeValues.end,
                      if (_selectedCountry != null) 'location': _selectedCountry!.name,
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          24.0.height,
        ],
      ),
    );
  }
}
