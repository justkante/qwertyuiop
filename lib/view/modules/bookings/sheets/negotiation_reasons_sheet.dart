import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/onboarding/widgets/search_input_field.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NegotiationReasonsSheet extends ConsumerStatefulWidget {
  const NegotiationReasonsSheet({super.key});

  @override
  ConsumerState<NegotiationReasonsSheet> createState() => _NegotiationReasonsSheetState();
}

class _NegotiationReasonsSheetState extends ConsumerState<NegotiationReasonsSheet> {
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
    final getNegotiationReasons = ref.watch(fetchRenegotiationReasonsProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          12.0.height,

          // MARK: Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Reason for Negotiating".toTitleCase(),
                style: context.textTheme.headlineSmall?.copyWith(fontSize: 18),
              ),
            ],
          ),

          20.0.height,
          Expanded(
            child: getNegotiationReasons.when(
              data: (reasons) {
                final filteredReasons = reasons
                    .where((reason) => reason.reason!.toLowerCase().contains(_searchQuery))
                    .toList();

                return Column(
                  children: [
                    // MARK: Search Field
                    SearchTextInputField(
                      hintText: 'Search Reason...',
                      controller: searchController,
                    ),
                    12.0.height,
                    Expanded(
                      child: Scrollbar(
                        interactive: true,
                        thickness: 2,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredReasons.length,
                          separatorBuilder: (_, __) => 0.0.height,
                          itemBuilder: (context, index) {
                            final reason = filteredReasons[index];

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                reason.reason ?? '',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.subHeading,
                                ),
                              ),
                              onTap: () {
                                context.pop(reason);
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
