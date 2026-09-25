import 'package:creatify_mobile/data/models/responses/creator_availabiity_dto.dart';
import 'package:creatify_mobile/view/modules/onboarding/widgets/search_input_field.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StateSheet extends ConsumerStatefulWidget {
  const StateSheet({super.key});

  @override
  ConsumerState<StateSheet> createState() => _BankSheetState();
}

class _BankSheetState extends ConsumerState<StateSheet> {
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
    final getStatesList = ref.watch(fetchStatesProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          12.0.height,

          // MARK: Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose a Location',
                style: context.textTheme.headlineSmall?.copyWith(fontSize: 18),
              ),
              6.0.width,
              SvgPicture.asset(
                AppImages.bank,
                width: 24,
                height: 24,
              ),
            ],
          ),

          20.0.height,
          Expanded(
            child: Column(
              children: [
                // MARK: Search Field
                SearchTextInputField(
                  hintText: 'Search or type location...',
                  controller: searchController,
                ),
                12.0.height,
                Expanded(
                  child: getStatesList.when(
                    data: (states) {
                      final filteredStates = states
                          .where((state) => state.name != null && state.name!.toLowerCase().contains(_searchQuery))
                          .toList();

                      return _buildStateList(filteredStates);
                    },
                    error: (_, __) => _buildStateList([]),
                    loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateList(List<StatesItemDto> filteredStates) {
    final customName = searchController.text.trim();

    if (filteredStates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_city_outlined, size: 44, color: AppColors.body),
              12.0.height,
              Text(
                customName.isNotEmpty
                    ? 'No matching predefined states.'
                    : 'Search or type your city or state',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1B3131)),
              ),
              16.0.height,
              if (customName.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    context.pop(StatesItemDto(name: customName, id: customName));
                  },
                  icon: const Icon(Icons.check, size: 18, color: Colors.white),
                  label: Text('Select "$customName"', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Scrollbar(
      interactive: true,
      thickness: 2,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: filteredStates.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.grey100),
        itemBuilder: (context, index) {
          final state = filteredStates[index];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              state.name ?? '',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.subHeading,
              ),
            ),
            onTap: () {
              context.pop(state);
            },
          );
        },
      ),
    );
  }
}
