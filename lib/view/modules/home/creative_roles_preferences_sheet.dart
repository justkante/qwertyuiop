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

class CreativeRolesPreferencesSheet extends ConsumerStatefulWidget {
  const CreativeRolesPreferencesSheet({super.key});

  static final List<NicheItemDto> kCreativeRolesGroups = [
    NicheItemDto(
      id: 'photography_videography',
      name: 'Photography & Videography',
      categories: [
        NicheItemDto(id: 'photographers', name: 'Photographers'),
        NicheItemDto(id: 'videographers', name: 'Videographers / Cinematographers'),
        NicheItemDto(id: 'drone_operators', name: 'Drone Operators'),
        NicheItemDto(id: 'editors', name: 'Editors'),
        NicheItemDto(id: 'animators', name: 'Animators'),
      ],
    ),
    NicheItemDto(
      id: 'beauty_styling',
      name: 'Beauty & Styling',
      categories: [
        NicheItemDto(id: 'makeup_artists', name: 'Makeup Artists'),
        NicheItemDto(id: 'hair_stylists', name: 'Hair Stylists'),
        NicheItemDto(id: 'stylists', name: 'Stylists'),
        NicheItemDto(id: 'nail_technicians', name: 'Nail Technicians'),
        NicheItemDto(id: 'wardrobe_consultants', name: 'Wardrobe Consultants'),
      ],
    ),
    NicheItemDto(
      id: 'talent_influencers',
      name: 'Talent & Influencers',
      categories: [
        NicheItemDto(id: 'influencers_brand_ambassadors', name: 'Influencers / Brand Ambassadors'),
        NicheItemDto(id: 'models', name: 'Models'),
        NicheItemDto(id: 'content_creators', name: 'Content Creators'),
      ],
    ),
    NicheItemDto(
      id: 'content_media',
      name: 'Content & Media',
      categories: [
        NicheItemDto(id: 'ugc_creators', name: 'UGC Creators'),
        NicheItemDto(id: 'content_writers', name: 'Content Writers'),
        NicheItemDto(id: 'presenters', name: 'Presenters'),
        NicheItemDto(id: 'social_media_managers', name: 'Social Media Managers'),
        NicheItemDto(id: 'copywriters', name: 'Copywriters'),
      ],
    ),
    NicheItemDto(
      id: 'music_audio',
      name: 'Music & Audio',
      categories: [
        NicheItemDto(id: 'voiceover_artists', name: 'Voiceover Artists'),
        NicheItemDto(id: 'musicians', name: 'Musicians'),
        NicheItemDto(id: 'sound_engineers', name: 'Sound Engineers'),
        NicheItemDto(id: 'djs_producers', name: 'DJs / Producers'),
      ],
    ),
    NicheItemDto(
      id: 'design_branding',
      name: 'Design & Branding',
      categories: [
        NicheItemDto(id: 'graphic_designers', name: 'Graphic Designers'),
        NicheItemDto(id: 'brand_strategists', name: 'Brand Strategists'),
        NicheItemDto(id: 'illustrators', name: 'Illustrators'),
        NicheItemDto(id: 'ui_ux_designers', name: 'UI/UX Designers'),
      ],
    ),
    NicheItemDto(
      id: 'spaces_venues',
      name: 'Spaces & Venues',
      categories: [
        NicheItemDto(id: 'studio_owners', name: 'Studio Owners'),
        NicheItemDto(id: 'event_spaces', name: 'Event Spaces'),
        NicheItemDto(id: 'galleries', name: 'Galleries'),
        NicheItemDto(id: 'production_lofts', name: 'Production Lofts'),
      ],
    ),
    NicheItemDto(
      id: 'events_experiences',
      name: 'Events & Experiences',
      categories: [
        NicheItemDto(id: 'event_planners', name: 'Event Planners'),
        NicheItemDto(id: 'hosts_mcs', name: 'Hosts / MCs'),
        NicheItemDto(id: 'promoters', name: 'Promoters'),
      ],
    ),
    NicheItemDto(
      id: 'tech_digital',
      name: 'Tech & Digital',
      categories: [
        NicheItemDto(id: 'web_developers', name: 'Web Developers'),
        NicheItemDto(id: 'digital_marketers', name: 'Digital Marketers'),
        NicheItemDto(id: 'app_creators', name: 'App Creators'),
      ],
    ),
  ];

  @override
  ConsumerState<CreativeRolesPreferencesSheet> createState() => _CreativeRolesPreferencesSheetState();
}

class _CreativeRolesPreferencesSheetState extends ConsumerState<CreativeRolesPreferencesSheet> {
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
      final savedRoles = SharedPrefManager.recruiterCreativeRoles;
      final allSubs = CreativeRolesPreferencesSheet.kCreativeRolesGroups.expand((n) => n.categories ?? []);
      if (savedRoles.isNotEmpty) {
        final Set<String> ids = allSubs.where((s) => savedRoles.contains(s.name)).map<String>((s) => s.id ?? '').toSet();
        selectedSubCategoryIds = ids;
      } else {
        final Set<String> ids = allSubs.map<String>((s) => s.id ?? '').toSet();
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
                'Creative Roles',
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
            'Browse by category and pick the roles you need.',
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
            hintText: 'Search creative roles...',
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
              for (var group in CreativeRolesPreferencesSheet.kCreativeRolesGroups) {
                for (var sub in group.categories ?? []) {
                  if (selectedSubCategoryIds.contains(sub.id)) {
                    selectedNames.add(sub.name ?? '');
                  }
                }
              }
              SharedPrefManager.recruiterCreativeRoles = selectedNames;
              ToastDialog.showSuccess('Creative Roles updated successfully', context);
              Navigator.of(context).pop(true);
            },
          ),
          16.0.height,
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final nicheGroups = CreativeRolesPreferencesSheet.kCreativeRolesGroups;

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
