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

class BankSheet extends ConsumerStatefulWidget {
  const BankSheet({super.key});

  @override
  ConsumerState<BankSheet> createState() => _BankSheetState();
}

class _BankSheetState extends ConsumerState<BankSheet> {
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
    final getBankList = ref.watch(fetchBanksProvider);

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
                'Choose a Bank Account',
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
            child: getBankList.when(
              data: (banks) {
                final filteredBanks =
                    banks.where((bank) => bank.name!.toLowerCase().contains(_searchQuery)).toList();

                return Column(
                  children: [
                    // MARK: Search Field
                    SearchTextInputField(
                      hintText: 'Search Bank...',
                      controller: searchController,
                    ),
                    12.0.height,
                    Expanded(
                      child: Scrollbar(
                        interactive: true,
                        thickness: 2,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredBanks.length,
                          separatorBuilder: (_, __) => 0.0.height,
                          itemBuilder: (context, index) {
                            final bank = filteredBanks[index];

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                bank.name ?? '',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.subHeading,
                                ),
                              ),
                              onTap: () {
                                context.pop(bank);
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
