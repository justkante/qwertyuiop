import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/responses/countries_dto.dart';
import 'package:creatify_mobile/view/modules/authentication/get_countries_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/update_profile_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetCountrySheet extends ConsumerStatefulWidget {
  const SetCountrySheet({
    super.key,
  });

  @override
  ConsumerState<SetCountrySheet> createState() => _SetCountrySheetState();
}

class _SetCountrySheetState extends ConsumerState<SetCountrySheet> {
  final countryController = TextEditingController();

  CountriesItemDto? selectedCountry;

  @override
  Widget build(BuildContext context) {
    final updatingProfile = ref.watch(updateProfileProvider).isLoading;

    ref.listen(updateProfileProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();
        SharedPrefManager.countryUpdatedAt = DateTime.now().toIso8601String();
        ToastDialog.showSuccess('Country Updated!', context);
      }
      if (value is AsyncError) {
        if (value.error.toString().contains('cannot be changed')) {
          SharedPrefManager.countryUpdatedAt = DateTime.now().toIso8601String();

          context.pop();
        }

        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: updatingProfile,
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            24.0.height,
            Text(
              'Set Your Country',
              style: context.textTheme.displayMedium,
            ).animate().fadeIn(begin: 0, delay: 300.ms).slideY(begin: .1, end: 0),
            8.0.height,
            Text(
              'We need to know your country to set your currency and customize your experience',
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ).animate().fadeIn(begin: 0, delay: 400.ms).slideY(begin: .1, end: 0),
            25.0.height,
            TextInputField(
              header: "Country of Residence",
              hint: "Select your country of residence",
              controller: countryController,
              inputType: TextInputType.text,
              readOnly: true,
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.body,
                size: 18,
              ),
              onPressed: () {
                AppBottomSheet.showBottomSheet(
                  context,
                  widget: GetCountriesSheet(
                    onCountrySelected: (country) {
                      countryController.text = country.name ?? '';
                      selectedCountry = country;
                      setState(() {});
                    },
                  ),
                );
              },
              validator: validateGeneric,
            ),
            48.0.height,
            ListenableBuilder(
              listenable: Listenable.merge([
                countryController,
              ]),
              builder: (context, _) {
                bool isValid = validateRequiredFields([
                  countryController.text,
                ]);
                return MainButton(
                  text: 'Continue',
                  isLoading: updatingProfile,
                  onPressed: isValid
                      ? () {
                          if (Form.of(context).validate()) {
                            ref.read(updateProfileProvider.notifier).updateProfile(
                                  country: selectedCountry,
                                );
                          }
                        }
                      : null,
                ).animate().fadeIn(begin: 0, delay: 700.ms).slideY(begin: .1, end: 0);
              },
            ),
            12.0.height,
          ],
        ),
      ),
    );
  }
}
