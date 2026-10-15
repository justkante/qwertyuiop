import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/responses/niche_item_dto.dart';
import 'package:creatify_mobile/view/modules/onboarding/widgets/search_input_field.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchPreferencesSheet extends ConsumerStatefulWidget {
  const SearchPreferencesSheet({super.key});

  static final List<NicheItemDto> kProjectTypesGroups = [
    NicheItemDto(
      id: 'content_marketing',
      name: 'Content & Marketing',
      categories: [
        NicheItemDto(id: 'brand_campaigns', name: 'Brand Campaigns'),
        NicheItemDto(id: 'social_media_content', name: 'Social Media Content'),
        NicheItemDto(id: 'ugc_creator_content', name: 'UGC / Creator Content'),
        NicheItemDto(id: 'advertising_commercial', name: 'Advertising / Commercial'),
      ],
    ),
    NicheItemDto(
      id: 'production',
      name: 'Production',
      categories: [
        NicheItemDto(id: 'film_video_production', name: 'Film / Video Production'),
        NicheItemDto(id: 'music_audio_production', name: 'Music / Audio Production'),
        NicheItemDto(id: 'events', name: 'Events'),
        NicheItemDto(id: 'live_performance', name: 'Live Performance / Entertainment'),
      ],
    ),
    NicheItemDto(
      id: 'product_commercial',
      name: 'Product & Commercial',
      categories: [
        NicheItemDto(id: 'product_ecommerce', name: 'Product / E-commerce'),
        NicheItemDto(id: 'corporate_business', name: 'Corporate / Business Content'),
        NicheItemDto(id: 'real_estate_architecture', name: 'Real Estate / Architecture'),
        NicheItemDto(id: 'technology_apps', name: 'Technology / Apps'),
      ],
    ),
    NicheItemDto(
      id: 'fashion_lifestyle',
      name: 'Fashion & Lifestyle',
      categories: [
        NicheItemDto(id: 'fashion_beauty', name: 'Fashion / Beauty'),
        NicheItemDto(id: 'editorial', name: 'Editorial'),
        NicheItemDto(id: 'weddings_celebrations', name: 'Weddings / Celebrations'),
        NicheItemDto(id: 'travel_hospitality', name: 'Travel / Hospitality'),
      ],
    ),
    NicheItemDto(
      id: 'design_creative_direction',
      name: 'Design & Creative Direction',
      categories: [
        NicheItemDto(id: 'branding_design', name: 'Branding / Design Projects'),
        NicheItemDto(id: 'creative_direction', name: 'Creative Direction / Art Direction'),
        NicheItemDto(id: 'set_design', name: 'Set Design / Production Design'),
        NicheItemDto(id: 'other', name: 'Other'),
      ],
    ),
  ];

  @override
  ConsumerState<SearchPreferencesSheet> createState() => _SearchPreferencesSheetState();
}

class _SearchPreferencesSheetState extends ConsumerState<SearchPreferencesSheet> {
  Set<String> selectedSubCategoryIds = {};
  Set<String> collapsedCategoryIds = {};
  bool _initialized = false;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      final savedProjects = SharedPrefManager.recruiterTypesOfProjects;
      final allSubs = SearchPreferencesSheet.kProjectTypesGroups.expand((n) => n.categories ?? []);
      if (savedProjects.isNotEmpty) {
        final Set<String> ids = allSubs.where((s) => savedProjects.contains(s.name)).map<String>((s) => s.id ?? '').toSet();
        selectedSubCategoryIds = ids;
      }
      _initialized = true;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          12.0.height,

          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Projects I Hire For',
                style: context.textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black2,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.body,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          6.0.height,
          Text(
            'Select all that apply. This helps creators understand the types of work you commission.',
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: AppColors.body,
              fontSize: 12,
            ),
          ),
          16.0.height,

          // Search Bar
          SearchTextInputField(
            controller: searchController,
            hintText: 'Search project types...',
            onChanged: (val) => setState(() => searchQuery = val.trim().toLowerCase()),
          ),
          16.0.height,

          // Category list
          Expanded(
            child: SingleChildScrollView(
              child: _buildCategoryList(),
            ),
          ),
          16.0.height,

          // Save button
          MainButton(
            color: AppColors.primary,
            text: 'Save ${selectedSubCategoryIds.length} selections',
            onPressed: () {
              final selectedNames = <String>[];
              for (var group in SearchPreferencesSheet.kProjectTypesGroups) {
                for (var sub in group.categories ?? []) {
                  if (selectedSubCategoryIds.contains(sub.id)) {
                    selectedNames.add(sub.name ?? '');
                  }
                }
              }
              SharedPrefManager.recruiterTypesOfProjects = selectedNames;
              ToastDialog.showSuccess('Projects I Hire For updated successfully', context);
              Navigator.of(context).pop(true);
            },
          ),
          16.0.height,
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final nicheGroups = SearchPreferencesSheet.kProjectTypesGroups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...nicheGroups.map<Widget>((niche) {
          final categories = niche.categories ?? [];
          final filteredCategories = searchQuery.isEmpty
              ? categories
              : categories.where((sub) => (sub.name ?? '').toLowerCase().contains(searchQuery)).toList();

          if (searchQuery.isNotEmpty && filteredCategories.isEmpty && !(niche.name ?? '').toLowerCase().contains(searchQuery)) {
            return const SizedBox.shrink();
          }

          final displayCategories = searchQuery.isNotEmpty && filteredCategories.isNotEmpty ? filteredCategories : categories;
          final isCollapsed = collapsedCategoryIds.contains(niche.id);
          final isExpanded = searchQuery.isNotEmpty || !isCollapsed;
          final selectedCount = categories.where((sub) => selectedSubCategoryIds.contains(sub.id)).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isCollapsed) {
                      collapsedCategoryIds.remove(niche.id);
                    } else {
                      collapsedCategoryIds.add(niche.id ?? '');
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          niche.name ?? '',
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: AppColors.black2,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selectedCount > 0)
                            Text(
                              '$selectedCount selected ',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: AppColors.body,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded && displayCategories.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: displayCategories.map<Widget>((sub) {
                    final isSelected = selectedSubCategoryIds.contains(sub.id);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedSubCategoryIds.remove(sub.id);
                          } else {
                            selectedSubCategoryIds.add(sub.id ?? '');
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.grey300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              const Icon(Icons.check, size: 13, color: Colors.white),
                              4.0.width,
                            ] else ...[
                              Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: AppColors.grey400),
                                ),
                              ),
                              6.0.width,
                            ],
                            Text(
                              sub.name ?? '',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: isSelected ? Colors.white : AppColors.subHeading,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                12.0.height,
              ],
            ],
          );
        }),
      ],
    );
  }
}
