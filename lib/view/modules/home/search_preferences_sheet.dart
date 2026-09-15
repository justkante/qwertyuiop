import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/data/models/responses/niche_item_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/update_preferences_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
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

  @override
  ConsumerState<SearchPreferencesSheet> createState() => _SearchPreferencesSheetState();
}

class _SearchPreferencesSheetState extends ConsumerState<SearchPreferencesSheet> {
  Set<String> selectedSubCategoryIds = {};
  String? expandedCategoryId;
  bool showAllParentCategories = false;
  bool _initialized = false;

  List<NicheItemDto> _parseNicheGroups(AsyncValue<dynamic> nichesAsync) {
    final value = nichesAsync.value;
    if (value is List<NicheItemDto>) {
      return value;
    }
    if (value is List) {
      return value.whereType<NicheItemDto>().toList();
    }
    return [];
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

    if (!_initialized &&
        nichesAsync.hasValue &&
        preferencesAsync.hasValue &&
        preferences.isNotEmpty) {
      final preferenceIds = preferences.map((p) => p.id ?? '').toSet();
      final allSubIds =
          nicheGroups.expand((n) => n.categories ?? []).map((sub) => sub.id ?? '').toSet();

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
        context.pop();
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: updatingPreferences,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(
                  'Search Preferences',
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black2,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.pop(),
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
                'Choose categories to quickly find the right creatives for your needs',
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.body,
                ),
              ),
            ),
            24.0.height,
            Expanded(
              child: SingleChildScrollView(
                child: _buildCategoryList(nichesAsync, preferencesAsync, nicheGroups),
              ),
            ),
            12.0.height,
            MainButton(
              color: AppColors.highlightCoral,
              isLoading: updatingPreferences,
              text: 'Save Preferences',
              onPressed: () {
                ref
                    .read(updatePreferencesProvider.notifier)
                    .updatePreferences(selectedSubCategoryIds.toList());
              },
            ),
            12.0.height,
          ],
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

    if (isLoading) {
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

    if (hasError) {
      return Center(
        child: Text((nichesAsync.error ?? preferencesAsync.error).toString()),
      );
    }

    final visibleGroups = showAllParentCategories ? nicheGroups : nicheGroups.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...visibleGroups.map<Widget>((niche) {
          final isExpanded = expandedCategoryId == niche.id;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    expandedCategoryId = isExpanded ? null : niche.id;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          niche.name ?? '',
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: AppColors.btnText,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppColors.btnText,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded && (niche.categories?.isNotEmpty ?? false)) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (niche.categories ?? []).map<Widget>((sub) {
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.highlightCoral : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.highlightCoral : AppColors.grey300,
                          ),
                        ),
                        child: Text(
                          sub.name ?? '',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: isSelected ? Colors.white : AppColors.subHeading,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                8.0.height,
              ],
            ],
          );
        }),
        if (nicheGroups.length > 5) ...[
          12.0.height,
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showAllParentCategories = !showAllParentCategories;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    showAllParentCategories ? 'Show Less' : 'Show More',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.highlightCoral,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  4.0.width,
                  Icon(
                    showAllParentCategories ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.highlightCoral,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
