import 'package:creatify_mobile/data/models/responses/countries_dto.dart';
import 'package:creatify_mobile/view/modules/authentication/vm/country_providers.dart';
import 'package:creatify_mobile/view/modules/onboarding/widgets/search_input_field.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GetCountriesSheet extends ConsumerStatefulWidget {
  final List<String>? excludedCountries;
  final ValueChanged<CountriesItemDto>? onCountrySelected;
  const GetCountriesSheet({super.key, this.excludedCountries, this.onCountrySelected});

  @override
  ConsumerState<GetCountriesSheet> createState() => _GetCountriesSheetState();
}

class _GetCountriesSheetState extends ConsumerState<GetCountriesSheet> {
  final searchController = TextEditingController();

  String _searchQuery = '';

  void _onSearchChanged() {
    setState(() {
      _searchQuery = searchController.text.toLowerCase();
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
    final getCountries = ref.watch(getCountriesProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          12.0.height,

          // MARK: Title
          Center(
            child: Text(
              'Select Your Country of Residence',
              style: context.textTheme.headlineSmall?.copyWith(fontSize: 18),
            ),
          ),

          20.0.height,
          Expanded(
            child: getCountries.when(
              data: (countries) {
                final filteredCountries = countries
                    .where((country) => country.name!.toLowerCase().contains(_searchQuery))
                    .where((country) => widget.excludedCountries?.contains(country.id) != true)
                    .toList();

                return Column(
                  children: [
                    // MARK: Search Field
                    SearchTextInputField(
                      hintText: 'Search Countries...',
                      controller: searchController,
                    ),
                    12.0.height,
                    Expanded(
                      child: Scrollbar(
                        interactive: true,
                        thickness: 2,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredCountries.length,
                          separatorBuilder: (_, __) => 12.0.height,
                          itemBuilder: (context, index) {
                            final country = filteredCountries[index];

                            return InkWell(
                              onTap: () {
                                context.pop();
                                widget.onCountrySelected!(country);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.btnInactive,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    "${country.flagEmoji} ${country.name} (${country.currencySymbol})",
                                    style: context.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.subHeading,
                                      fontFamily: FontFamily.inter,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
              error: (error, stackTrace) => Text('Error: $error'),
              loading: () => const Center(child: CircularProgressIndicator.adaptive()),
            ),
          ),
        ],
      ),
    );
  }
}
