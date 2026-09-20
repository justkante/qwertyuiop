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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(
                  'Filter Jobs',
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
                'Narrow down your job search',
                style: context.textTheme.bodySmall?.copyWith(color: AppColors.body),
              ),
            ),
            24.0.height,

            _buildSectionTitle('Categories'),
            12.0.height,
            ref.watch(fetchCreatorNichesProvider).when(
              data: (categories) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = _selectedCategories.contains(cat.id);
                  return FilterChip(
                    label: Text(cat.name ?? '', style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.body)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) _selectedCategories.add(cat.id!);
                        else _selectedCategories.remove(cat.id);
                      });
                    },
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    backgroundColor: AppColors.grey50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  );
                }).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Text('Error loading categories'),
            ),
            24.0.height,

            _buildSectionTitle('Budget Range'),
            RangeSlider(
              values: _currentRangeValues,
              min: 0,
              max: 200000,
              divisions: 200,
              activeColor: AppColors.primary,
              onChanged: (values) => setState(() => _currentRangeValues = values),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceBox('Min', _currentRangeValues.start),
                _buildPriceBox('Max', _currentRangeValues.end),
              ],
            ),
            24.0.height,

            _buildSectionTitle('Location'),
            12.0.height,
            InkWell(
              onTap: () {
                AppBottomSheet.showBottomSheet(
                  context,
                  widget: GetCountriesSheet(
                    onCountrySelected: (country) => setState(() => _selectedCountry = country),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedCountry?.name ?? 'Anywhere', style: const TextStyle(fontSize: 13)),
                    const Icon(Icons.location_on_outlined, color: AppColors.body, size: 18),
                  ],
                ),
              ),
            ),
            32.0.height,

            Row(
              children: [
                Expanded(
                  child: MainButton(
                    text: 'Reset',
                    color: AppColors.grey100,
                    textColor: AppColors.black2,
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
                    text: 'Apply Filters',
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15));
  }

  Widget _buildPriceBox(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.body)),
        4.0.height,
        Container(
          width: MediaQuery.sizeOf(context).width * 0.4,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(10)),
          child: Text(value.amountWithCurrency('NGN'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
