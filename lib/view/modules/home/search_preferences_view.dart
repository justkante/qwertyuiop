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

    // Auto-select sub-categories matching saved preferences once both loads complete
    if (!_initialized &&
        nichesAsync.hasValue &&
        preferencesAsync.hasValue &&
        preferences.isNotEmpty) {
      final preferenceIds = preferences.map((p) => p.id ?? '').toSet();
      final allSubIds =
          nicheGroups.expand((n) => n.categories ?? []).map((sub) => sub.id ?? '').toSet();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            selectedSubCategoryIds = preferenceIds.intersection(allSubIds);
            _initialized = true;
          });
        }
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Search Preferences',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.subHeading,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose categories to quickly find the right creatives for your needs',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.body,
                ),
              ),
              24.0.height,
              _buildCategoryList(nichesAsync, preferencesAsync, nicheGroups),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
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
                  ref
                      .read(updatePreferencesProvider.notifier)
                      .updatePreferences(selectedSubCategoryIds.toList());
                },
              ),
              12.0.height,
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
        child: Text(
          (nichesAsync.error ?? preferencesAsync.error).toString(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: nicheGroups.map<Widget>((niche) {
        final nicheId = niche.id ?? '';
        final isExpanded = expandedCategoryIds.contains(nicheId);
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
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        niche.name ?? '',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.subHeading,
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
      }).toList(),
    );
  }
}
