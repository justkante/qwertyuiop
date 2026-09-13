import 'package:creatify_mobile/view/modules/onboarding/widgets/search_input_field.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CreatorNicheSheet extends ConsumerStatefulWidget {
  final List<String>? excludedNicheIds;
  const CreatorNicheSheet({super.key, this.excludedNicheIds});

  @override
  ConsumerState<CreatorNicheSheet> createState() => _CreatorNicheSheetState();
}

class _CreatorNicheSheetState extends ConsumerState<CreatorNicheSheet> {
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
    final getCreatorNiches = ref.watch(fetchCreatorNichesProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          12.0.height,

          // MARK: Title
          Center(
            child: Text(
              'Select Your Creator Niche',
              style: context.textTheme.headlineSmall?.copyWith(fontSize: 18),
            ),
          ),

          20.0.height,
          Expanded(
            child: getCreatorNiches.when(
              data: (niches) {
                final filteredNiches = niches
                    .where((niche) => niche.name!.toLowerCase().contains(_searchQuery))
                    .where((niche) => widget.excludedNicheIds?.contains(niche.id) != true)
                    .toList();

                return Column(
                  children: [
                    // MARK: Search Field
                    SearchTextInputField(
                      hintText: 'Search Niches...',
                      controller: searchController,
                    ),
                    12.0.height,
                    Expanded(
                      child: Scrollbar(
                        interactive: true,
                        thickness: 2,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredNiches.length,
                          separatorBuilder: (_, __) => 0.0.height,
                          itemBuilder: (context, index) {
                            final niche = filteredNiches[index];

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                niche.name ?? '',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.subHeading,
                                ),
                              ),
                              onTap: () {
                                context.pop(niche);
                              },
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
