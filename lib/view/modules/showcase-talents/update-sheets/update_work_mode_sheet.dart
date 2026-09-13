import 'package:creatify_mobile/data/models/requests/update_availability_req.dart';
import 'package:creatify_mobile/data/models/responses/creator_availabiity_dto.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/states_sheet.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_dropdown.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UpdateWorkModeSheet extends StatefulWidget {
  final WorkPreference? workPreference;
  const UpdateWorkModeSheet({
    super.key,
    this.workPreference,
  });

  @override
  State<UpdateWorkModeSheet> createState() => _UpdateWorkModeSheetState();
}

class _UpdateWorkModeSheetState extends State<UpdateWorkModeSheet> {
  final GlobalKey<State> workModeKey = GlobalKey();

  final workMode = TextEditingController();
  final chooseLocation = TextEditingController();
  bool canTravel = false;

  StatesItemDto? selectedState;

  @override
  void initState() {
    super.initState();
    if (widget.workPreference != null) {
      workMode.text = widget.workPreference?.workMode?.toTitleCase() ?? '';
      chooseLocation.text = widget.workPreference?.state?.name ?? '';
      canTravel = widget.workPreference?.availableToTravel ?? false;
      selectedState = widget.workPreference?.state;
    }
  }

  @override
  void dispose() {
    workMode.dispose();
    chooseLocation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        12.0.height,
        // MARK: Title
        Row(
          children: [
            Text(
              'Update Work Mode',
              style: context.textTheme.headlineSmall?.copyWith(fontSize: 23),
            ),
            6.0.width,
            SvgPicture.asset(AppImages.calendarLine)
          ],
        ),
        6.0.height,
        Text(
          "Choose the days and times you're available for bookings",
          style: context.textTheme.bodySmall,
        ),
        21.0.height,

        // MARK: Map Image
        Image.asset(AppImages.dummyMap),
        32.0.height,

        // MARK: Form
        TextInputField(
          key: workModeKey,
          header: 'Select Work Mode',
          controller: workMode,
          hint: 'Select',
          inputType: TextInputType.text,
          onPressed: () async {
            await platformSpecificDropdown(
              context: context,
              items: ['Remote', 'On-site', 'Hybrid'],
              value: workMode.text,
              onChanged: (value) {
                workMode.text = value!;
              },
              key: workModeKey,
            );
          },
          readOnly: true,
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.body,
            size: 18,
          ),
          validator: validateGeneric,
        ),
        24.0.height,

        TextInputField(
          header: 'Choose your Location',
          controller: chooseLocation,
          hint: 'Select',
          inputType: TextInputType.text,
          onPressed: () async {
            selectedState = await AppBottomSheet.showBottomSheet(
              context,
              widget: const StateSheet(),
            );

            if (selectedState != null) {
              chooseLocation.text = selectedState?.name ?? '';
            }
          },
          readOnly: true,
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.body,
            size: 18,
          ),
          validator: validateGeneric,
        ),
        24.0.height,

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Available to Travel",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.subHeading,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.grey300,
                inactiveThumbColor: Colors.white,
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                trackOutlineWidth: WidgetStateProperty.all(0.0),
                value: canTravel,
                onChanged: (value) {
                  setState(() {
                    canTravel = value;
                  });
                },
              ),
            )
          ],
        ),
        100.0.height,

        ListenableBuilder(
          listenable: Listenable.merge([
            workMode,
            chooseLocation,
          ]),
          builder: (context, child) {
            bool isValid = validateRequiredFields([
              workMode.text,
              chooseLocation.text,
            ]);
            return MainButton(
              text: 'Update',
              onPressed: isValid
                  ? () {
                      final UpdateAvailabilityReq req = UpdateAvailabilityReq(
                        workMode: workMode.text.toLowerCase(),
                        stateId: selectedState?.id,
                        availableToTravel: canTravel,
                      );

                      context.pop(req);
                    }
                  : null,
            );
          },
        ),
        30.0.height,
      ],
    );
  }
}
