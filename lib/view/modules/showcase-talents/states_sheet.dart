import 'package:creatify_mobile/data/models/responses/creator_availabiity_dto.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
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
  final CreatorProfileDto? creatorProfile;
  final bool isOnSiteBooking;
  const StateSheet({
    super.key,
    this.creatorProfile,
    this.isOnSiteBooking = false,
  });

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

  String _cleanCityName(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    if (raw.contains(',')) {
      return raw.split(',').first.trim();
    }
    return raw.trim();
  }

  @override
  Widget build(BuildContext context) {
    final statesAsync = ref.watch(fetchStatesProvider);

    return statesAsync.when(
      data: (apiStates) {
        List<StatesItemDto> countryStates = List.from(apiStates);

        if (widget.isOnSiteBooking && widget.creatorProfile != null) {
          if (widget.creatorProfile?.location != null && widget.creatorProfile!.location!.isNotEmpty) {
            final loc = widget.creatorProfile!.location!;
            if (!countryStates.any((s) => (s.name ?? '').toLowerCase() == loc.toLowerCase())) {
              countryStates.insert(0, StatesItemDto(id: loc, name: loc));
            }
          }
        }

        if (_searchQuery.isNotEmpty) {
          countryStates = countryStates
              .where((state) => (state.name ?? '').toLowerCase().contains(_searchQuery))
              .toList();
        }

        countryStates.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              12.0.height,
              // Title
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
                    // Search Field
                    SearchTextInputField(
                      hintText: 'Search location',
                      controller: searchController,
                    ),
                    12.0.height,
                    Expanded(
                      child: _buildStateList(countryStates),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
              12.0.height,
              const Text('Loading Locations...'),
            ],
          ),
        ),
      ),
      error: (err, _) => SizedBox(
        height: 300,
        child: Center(
          child: Text('Error loading locations: $err'),
        ),
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
                    ? 'No matching states found.'
                    : 'Search or type your city or state',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1B3131)),
              ),
              16.0.height,
              if (customName.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    context.pop(StatesItemDto(id: customName, name: customName));
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
          final displayName = _cleanCityName(state.name);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              displayName,
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
