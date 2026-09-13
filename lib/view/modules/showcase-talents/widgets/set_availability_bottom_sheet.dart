import 'package:creatify_mobile/data/models/requests/update_availability_req.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_dropdown.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SetAvailabilityBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final UnavailableDate? existingUnavailableDate;

  const SetAvailabilityBottomSheet({
    super.key,
    required this.selectedDate,
    this.existingUnavailableDate,
  });

  @override
  State<SetAvailabilityBottomSheet> createState() => _SetAvailabilityBottomSheetState();
}

class _SetAvailabilityBottomSheetState extends State<SetAvailabilityBottomSheet> {
  final GlobalKey<State> timeSlotKey = GlobalKey();
  final TextEditingController timeSlotController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  String selectedTimeSlot = 'All Day';
  bool showReasonField = false;

  final List<String> timeSlots = [
    'All Day',
    'Morning (8AM - 11AM)',
    'Afternoon (12PM - 3PM)',
    'Evening (4PM - 9PM)',
    'Night (10PM - 7AM)',
  ];

  final Map<String, Map<String, String?>> timeSlotMapping = {
    'All Day': {'startTime': null, 'endTime': null},
    'Morning (8AM - 11AM)': {'startTime': '08:00', 'endTime': '11:00'},
    'Afternoon (12PM - 3PM)': {'startTime': '12:00', 'endTime': '15:00'},
    'Evening (4PM - 9PM)': {'startTime': '16:00', 'endTime': '21:00'},
    'Night (10PM - 7AM)': {'startTime': '22:00', 'endTime': '07:00'},
  };

  @override
  void initState() {
    super.initState();

    // If editing existing unavailable date, prefill the form
    if (widget.existingUnavailableDate != null) {
      _prefillExistingData();
    } else {
      timeSlotController.text = selectedTimeSlot;
    }
  }

  void _prefillExistingData() {
    final existing = widget.existingUnavailableDate!;

    if (existing.isFullDay == true) {
      selectedTimeSlot = 'All Day';
      showReasonField = false;
    } else {
      // Determine time slot based on start and end time
      final startTime = existing.startTime;
      final endTime = existing.endTime;

      if (startTime == '08:00' && endTime == '11:00') {
        selectedTimeSlot = 'Morning (8AM - 11AM)';
      } else if (startTime == '12:00' && endTime == '15:00') {
        selectedTimeSlot = 'Afternoon (12PM - 3PM)';
      } else if (startTime == '16:00' && endTime == '21:00') {
        selectedTimeSlot = 'Evening (4PM - 9PM)';
      } else if (startTime == '22:00' && endTime == '07:00') {
        selectedTimeSlot = 'Night (10PM - 7AM)';
      } else {
        selectedTimeSlot = 'All Day'; // Default fallback
      }

      showReasonField = true;
      if (existing.reason != null) {
        reasonController.text = existing.reason!;
      }
    }

    timeSlotController.text = selectedTimeSlot;
  }

  @override
  void dispose() {
    timeSlotController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  void _onTimeSlotChanged(String? value) {
    if (value != null) {
      setState(() {
        selectedTimeSlot = value;
        timeSlotController.text = value;
        showReasonField = value != 'All Day';

        // Clear reason if All Day is selected
        if (!showReasonField) {
          reasonController.clear();
        }
      });
    }
  }

  void _confirmUnavailability() {
    final timeMapping = timeSlotMapping[selectedTimeSlot]!;

    final unavailableDate = UnavailableDate(
      date: widget.selectedDate,
      isFullDay: selectedTimeSlot == 'All Day',
      startTime: timeMapping['startTime'],
      endTime: timeMapping['endTime'],
      reason: showReasonField && reasonController.text.isNotEmpty ? reasonController.text : null,
    );

    Navigator.of(context).pop(unavailableDate);
  }

  String get _formattedMonth {
    return DateFormat('MMMM').format(widget.selectedDate);
  }

  String get _formattedDate {
    return DateFormat('d').format(widget.selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with close button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 24),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.black2,
                ),
              ),
            ),
          ],
        ),
        24.0.height,

        // Title and date
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              children: [
                Text(
                  _formattedMonth,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 19,
                    color: AppColors.subHeading,
                  ),
                ),
                16.0.height,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.highlightCoral,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formattedDate,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        24.0.height,

        // Time slot dropdown
        TextInputField(
          key: timeSlotKey,
          header: widget.existingUnavailableDate != null
              ? 'Edit Time Unavailable'
              : 'Select Time Unavailable',
          controller: timeSlotController,
          hint: 'Select time slot',
          inputType: TextInputType.text,
          validator: validateGeneric,
          readOnly: true,
          onPressed: () async {
            await platformSpecificDropdown(
              context: context,
              items: timeSlots,
              value: selectedTimeSlot,
              onChanged: _onTimeSlotChanged,
              key: timeSlotKey,
            );
          },
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.body,
            size: 18,
          ),
        ),

        // Reason field (conditionally shown)
        if (showReasonField) ...[
          16.0.height,
          TextInputField(
            header: 'Reason',
            controller: reasonController,
            hint: 'Enter reason (optional)',
            inputType: TextInputType.text,
            validator: null,
            maxLines: 3,
          ),
        ],
        64.0.height,

        // Confirm button
        ListenableBuilder(
          listenable: Listenable.merge([
            timeSlotController,
            if (showReasonField) reasonController,
          ]),
          builder: (context, child) {
            bool isValid = timeSlotController.text.isNotEmpty;

            return Column(
              children: [
                MainButton(
                  text: widget.existingUnavailableDate != null ? 'Update' : 'Confirm',
                  onPressed: isValid ? _confirmUnavailability : null,
                ),

                // Delete button for existing unavailable dates
                if (widget.existingUnavailableDate != null) ...[
                  16.0.height,
                  MainButton(
                    text: 'Remove Unavailability',
                    color: AppColors.highlightRed,
                    onPressed: () {
                      Navigator.of(context).pop('delete');
                    },
                  ),
                ],
              ],
            );
          },
        ),
        24.0.height,
      ],
    );
  }
}
