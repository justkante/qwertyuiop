import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/data/models/responses/niche_item_dto.dart';
import 'package:creatify_mobile/view/modules/home/creative_roles_preferences_sheet.dart';
import 'package:creatify_mobile/view/modules/home/vm/update_preferences_vm.dart';
import 'package:creatify_mobile/view/modules/search-talents/talent_filter_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/filter_creators_vm.dart';
import 'package:creatify_mobile/view/modules/tab-bar/tab_bar_view.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchPreferencesView extends ConsumerStatefulWidget {
  const SearchPreferencesView({
    super.key,
    this.allowMultipleParentExpansion = true,
  });

  final bool allowMultipleParentExpansion;

  @override
  ConsumerState<SearchPreferencesView> createState() => _SearchPreferencesViewState();
}

class _SearchPreferencesViewState extends ConsumerState<SearchPreferencesView> {
  Set<String> selectedSubCategoryIds = {};
  Set<String> expandedCategoryIds = {};
  bool _initialized = false;

  List<NicheItemDto> _parseNicheGroups(AsyncValue<dynamic> nichesAsync) {
    final value = nichesAsync.value;
    if (value is List<NicheItemDto> && value.isNotEmpty) {
      return value;
    }
    if (value is List && value.isNotEmpty) {
      return value.whereType<NicheItemDto>().toList();
    }
    return CreativeRolesPreferencesSheet.kCreativeRolesGroups;
  }

  List<Category> _parsePreferences(AsyncValue<dynamic> preferencesAsync) {
    final value = preferencesAsync.value;
    if (value is List<Category>) {
      return value;
    }
    if (value is List) {
      return value.whereType<Category>().toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final nichesAsync = ref.watch(fetchGroupedCreatorNichesProvider);
    final preferencesAsync = ref.watch(fetchPreferencesProvider);
    final nicheGroups = _parseNicheGroups(nichesAsync);
    final preferences = _parsePreferences(preferencesAsync);
    final updatingPreferences = ref.watch(updatePreferencesProvider).isLoading;

    if (!_initialized && preferences.isNotEmpty) {
      final preferenceIds = preferences.map((p) => p.id ?? '').toSet();
      final allSubIds = nicheGroups.expand((n) => n.categories ?? []).map((sub) => sub.id ?? '').toSet();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          selectedSubCategoryIds = preferenceIds.intersection(allSubIds);
          _initialized = true;
        });
      });
    } else if (!_initialized && nichesAsync.hasValue && preferencesAsync.hasValue) {
      _initialized = true;
    }

    ref.listen(updatePreferencesProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess(value.value ?? 'Preferences Updated', context);
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          NavigationService.instance.pushAndRemoveUntil(const TabBarSection());
        }
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: updatingPreferences,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                NavigationService.instance.pushAndRemoveUntil(const TabBarSection());
              }
            },
          ),
          title: Text(
            'Search Preferences',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.black2,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Choose categories to quickly find the right creatives for your needs',
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.body,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              24.0.height,
              _buildCategoryList(nichesAsync, preferencesAsync, nicheGroups),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.surface, width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MainButton(
                color: AppColors.highlightCoral,
                isLoading: updatingPreferences,
                text: 'Save Preferences',
                onPressed: () {
                  final selectedNames = <String>[];
                  for (var group in nicheGroups) {
                    for (var sub in group.categories ?? []) {
                      if (selectedSubCategoryIds.contains(sub.id) || selectedSubCategoryIds.contains(sub.name)) {
                        selectedNames.add(sub.name ?? '');
                      }
                    }
                  }

                  // 1. Set Find & Book Talents category notifier
                  categoriesNotifier.value = selectedNames.toSet();

                  // 2. Fast filter Find & Book Talents page
                  if (selectedNames.isNotEmpty) {
                    ref.read(hasSearchFiltersProvider.notifier).state = true;
                    ref.read(filterCreatorsProvider.notifier).filterCreators(
                      category: selectedNames
                          .map((e) => e.removeSpace().removeSlash().toLowerCase())
                          .join('|'),
                    );
                  }

                  // 3. Save preferences to backend
                  ref
                      .read(updatePreferencesProvider.notifier)
                      .updatePreferences(selectedSubCategoryIds.toList());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    AsyncValue<dynamic> nichesAsync,
    AsyncValue<dynamic> preferencesAsync,
    List<NicheItemDto> nicheGroups,
  ) {
    final isLoading = nichesAsync.isLoading || preferencesAsync.isLoading;
    final hasError = nichesAsync.hasError || preferencesAsync.hasError;

    if (isLoading && nicheGroups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Loading Categories...'),
            SizedBox(height: 8),
            CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ],
        ),
      );
    }

    if (hasError && nicheGroups.isEmpty) {
      return Center(
        child: Text(
          (nichesAsync.error ?? preferencesAsync.error).toString(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: nicheGroups.map<Widget>((niche) {
        final nicheId = niche.id ?? niche.name ?? '';
        final isExpanded = expandedCategoryIds.contains(nicheId);
        final categories = niche.categories ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (widget.allowMultipleParentExpansion) {
                    if (isExpanded) {
                      expandedCategoryIds.remove(nicheId);
                    } else {
                      expandedCategoryIds.add(nicheId);
                    }
                  } else {
                    if (isExpanded) {
                      expandedCategoryIds.clear();
                    } else {
                      expandedCategoryIds
                        ..clear()
                        ..add(nicheId);
                    }
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        niche.name ?? '',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.black2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.black2,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded && categories.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map<Widget>((sub) {
                  final subId = sub.id ?? sub.name ?? '';
                  final isSelected = selectedSubCategoryIds.contains(subId);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedSubCategoryIds.remove(subId);
                        } else {
                          selectedSubCategoryIds.add(subId);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.highlightCoral : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.highlightCoral : AppColors.grey300,
                        ),
                      ),
                      child: Text(
                        sub.name ?? '',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: isSelected ? Colors.white : AppColors.subHeading,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              12.0.height,
            ],
          ],
        );
      }).toList(),
    );
  }
}
