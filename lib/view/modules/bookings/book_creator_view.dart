import 'dart:developer';

import 'package:creatify_mobile/core/utils/constants.dart';
import 'package:creatify_mobile/data/models/requests/book_creator_req.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/data/models/responses/draft_booking_item_dto.dart';
import 'package:creatify_mobile/data/models/responses/unavailability_time_item_dto.dart';
import 'package:creatify_mobile/data/models/responses/user_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/creator_unavailabliity_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/request_sent_view.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/delivery_based_booking_vm.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/save_draft_booking_vm.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/transactions/widgets/transaction_line.dart';
import 'package:creatify_mobile/view/modules/webview/app_webview.dart';

import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_date_picker.dart';
import 'package:creatify_mobile/view/utils/app_dropdown.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/thousands_formatter.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/number_input_field.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:creatify_mobile/core/services/tour_service.dart';
import 'package:creatify_mobile/view/utils/tour/guarded_showcase.dart';
import 'package:creatify_mobile/view/utils/tour/tour_keys.dart';

class BookCreatorView extends ConsumerStatefulWidget {
  final CreatorProfileDto creatorProfile;
  final DraftingBookingItemDto? draftBooking;

  const BookCreatorView({
    super.key,
    required this.creatorProfile,
    this.draftBooking,
  });

  @override
  ConsumerState<BookCreatorView> createState() => _BookCreatorViewState();
}

class _BookCreatorViewState extends ConsumerState<BookCreatorView> {
  final GlobalKey<State> nicheKey = GlobalKey();
  final GlobalKey<State> workModeKey = GlobalKey();
  final GlobalKey<State> unitKey = GlobalKey();

  final TextEditingController jobDescriptionController = TextEditingController();
  final TextEditingController nicheController = TextEditingController();
  final TextEditingController workModeController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String selectedTypeOfBooking = "";
  Category? selectedNiche;
  bool _isFromDraft = false;
  TimeOfDay? selectedStartTime;
  CreatorUnavailabilityItemDto? selectedStartDate;
  List<Deliverable> deliverables = [];

  final TextEditingController priceController = TextEditingController();
  final TextEditingController equivalentPriceController = TextEditingController();

  // List to manage multiple deliverable cards
  List<DeliverableCardData> deliverableCards = [];

  // Accept Terms and Conditions
  bool acceptTerms = false;

  bool _tourStarted = false;
  late final ShowcaseView _showcaseView;

  @override
  void initState() {
    super.initState();
    _showcaseView = ShowcaseView.register(
      scope: 'book-creator',
      onFinish: () => TourService.markScreenDone(TourService.bookCreator),
    );
    // Initialize with one empty deliverable card
    _addDeliverableCard();
    _initFromDraftBooking();
    _tourStarted = !TourService.shouldShowScreenTour(TourService.bookCreator);
  }

  void _initFromDraftBooking() {
    final draft = widget.draftBooking;
    if (draft == null) return;

    _isFromDraft = true;

    // Booking type
    selectedTypeOfBooking = draft.bookingType ?? '';

    // Category/Niche
    if (draft.category != null) {
      nicheController.text = draft.category!.name ?? '';
      selectedNiche = Category(
        id: draft.category?.id,
        name: draft.category?.name,
      );
    }

    // Job description
    jobDescriptionController.text = draft.jobDescription ?? '';

    // Work mode (capitalize first letter since it's stored lowercase)
    if (draft.workMode != null && draft.workMode!.isNotEmpty) {
      workModeController.text = draft.workMode![0].toUpperCase() + draft.workMode!.substring(1);
    }

    // Start date
    if (draft.startDate != null) {
      startDateController.text = draft.startDate!.toFormattedDateWithYear();
      selectedStartDate = CreatorUnavailabilityItemDto(unavailableDate: draft.startDate);
    }

    // Start time
    if (draft.startTime != null && draft.startTime!.isNotEmpty) {
      final parts = draft.startTime!.split(':');
      if (parts.length >= 2) {
        final parsedHour = int.tryParse(parts[0]);
        final parsedMinute = int.tryParse(parts[1]);
        if (parsedHour != null && parsedMinute != null) {
          selectedStartTime = TimeOfDay(
            hour: parsedHour,
            minute: parsedMinute,
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && selectedStartTime != null) {
              startTimeController.text = selectedStartTime!.format(context);
            }
          });
        } else {
          log('Invalid startTime format in draft: "${draft.startTime}"');
        }
      }
    }

    // Duration and unit (stored as e.g. "2days", "3hours")
    if (draft.duration != null && draft.duration!.isNotEmpty) {
      final match = RegExp(r'(\d+)(\w+)').firstMatch(draft.duration!);
      if (match != null) {
        durationController.text = match.group(1) ?? '';
        unitController.text = match.group(2) ?? '';
      }
    } else {
      selectedTypeOfBooking == 'time-based' ? unitController.text = 'hours' : null;
    }

    // Location
    locationController.text = draft.location ?? '';

    // Price
    if (draft.offeredPrice != null && draft.offeredPrice!.isNotEmpty) {
      priceController.text = draft.offeredPrice!.formatDecimal();
      final val = num.tryParse(draft.offeredPrice!.removeCommas()) ?? 0;
      if (val != 0) {
        final exchangeRate = widget.creatorProfile.exchangeRateInfo?.rate ?? 0;
        equivalentPriceController.text = (val * exchangeRate).toString();
      }
    }

    // Deliverables
    if (draft.deliverables != null && draft.deliverables!.isNotEmpty) {
      // Remove the default empty card
      for (var card in deliverableCards) {
        card.dispose();
      }
      deliverableCards.clear();

      for (var deliverable in draft.deliverables!) {
        final card = DeliverableCardData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
        );
        card.descriptionController.text = deliverable.description ?? '';
        card.priceController.text = deliverable.price != null
            ? NumberFormat.decimalPattern().format(deliverable.price)
            : '';
        deliverableCards.add(card);
      }
      _updateDeliverables();
      _calculateTotalPrice();
    }
  }

  void _addDeliverableCard() {
    setState(() {
      deliverableCards.add(
        DeliverableCardData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
        ),
      );
    });
    _updateDeliverables();
  }

  void _removeDeliverableCard(int index) {
    if (deliverableCards.length > 1) {
      setState(() {
        deliverableCards[index].dispose();
        deliverableCards.removeAt(index);
      });
      _updateDeliverables();
      _calculateTotalPrice();
    }
  }

  void _updateDeliverables() {
    deliverables =
        deliverableCards.where((card) => card.isValid).map((card) => card.toDeliverable()).toList();
  }

  void _calculateTotalPrice() {
    double totalPrice = 0.0;
    for (var card in deliverableCards) {
      if (card.priceController.text.trim().isNotEmpty) {
        totalPrice += num.tryParse(card.priceController.text.replaceAll(',', '').trim()) ?? 0;
      }
    }
    priceController.text = NumberFormat.decimalPattern().format(totalPrice);
  }

  bool get _canAddDeliverable {
    if (deliverableCards.isEmpty) return false;
    // Only allow adding new deliverable if the last (most recent) one is completed
    return deliverableCards.last.isValid;
  }

  @override
  void dispose() {
    jobDescriptionController.dispose();
    nicheController.dispose();
    workModeController.dispose();
    startDateController.dispose();
    startTimeController.dispose();
    durationController.dispose();
    unitController.dispose();
    locationController.dispose();
    priceController.dispose();
    equivalentPriceController.dispose();

    // Dispose all deliverable card controllers
    for (var card in deliverableCards) {
      card.dispose();
    }

    _showcaseView.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final draftBookingLoading = ref.watch(saveDraftBookingProvider).isLoading;
    final bookingCreatorLoading = ref.watch(deliveryBasedCreatorBookingProvider).isLoading;

    ref.listen(saveDraftBookingProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();
        ToastDialog.showSuccess('Booking has been Saved', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    ref.listen(deliveryBasedCreatorBookingProvider, (_, value) {
      if (value is AsyncData) {
        context.pushReplacement(
          isTransparent: true,
          RequestSentView(
            creatorName: widget.creatorProfile.name,
          ),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    if (!_tourStarted) {
      _tourStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showcaseView.startShowCase([
          TourKeys.bookingTypeSelector,
          TourKeys.bookingFormDescription,
          TourKeys.bookingFormDetails,
        ]);
      });
    }

    return AbsorbPointer(
      absorbing: draftBookingLoading || bookingCreatorLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Book ${widget.creatorProfile.name?.split(' ').first}',
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
              // Booking Type (Radio Buttons)
              GuardedShowcase(
                showcaseKey: TourKeys.bookingTypeSelector,
                description:
                    'Select time-based for hourly/day work or deliverable-based for specific output.',
                targetBorderRadius: BorderRadius.circular(8),
                child: Row(
                  spacing: 4,
                  children: [
                    Text(
                      "Booking Type",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppColors.subHeading,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Tooltip(
                      preferBelow: true,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: AppColors.highlightCoral,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      message: """
[Time-based] Payment is released 48hours after the booking duration ends.

[Deliverable-based] You have 72 hours to approve each deliverable before payment is released.""",
                      textStyle: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.white,
                      ),
                      showDuration: 5000.ms,
                      triggerMode: TooltipTriggerMode.tap,
                      child: SvgPicture.asset(
                        AppImages.info,
                        height: 12,
                        width: 12,
                      ),
                    )
                  ],
                ),
              ),
              6.0.height,
              IgnorePointer(
                ignoring: _isFromDraft,
                child: Opacity(
                  opacity: _isFromDraft ? 0.6 : 1.0,
                  child: RadioGroup(
                    groupValue: selectedTypeOfBooking,
                    onChanged: (value) {
                      setState(() {
                        selectedTypeOfBooking = value ?? "";

                        if (selectedTypeOfBooking == 'time-based') {
                          // Set Unit to hours by default for time-based bookings
                          unitController.text = 'hours';
                        } else {
                          // Clear Unit for deliverable-based bookings
                          unitController.clear();
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Flexible(
                          child: RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.primary,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            title: Text(
                              'Time Based',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: selectedTypeOfBooking == 'time-based'
                                    ? AppColors.subHeading
                                    : null,
                              ),
                            ),
                            value: 'time-based',
                          ),
                        ),
                        Flexible(
                          child: RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.primary,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            title: Text(
                              'Deliverable Based',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: selectedTypeOfBooking == 'deliverable-based'
                                    ? AppColors.subHeading
                                    : null,
                              ),
                            ),
                            value: 'deliverable-based',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              18.0.height,

              // Forms
              TextInputField(
                key: nicheKey,
                header: 'Category/Niche',
                controller: nicheController,
                hint: (widget.creatorProfile.categories?.isNotEmpty == true)
                    ? 'Select Category/Niche'
                    : 'No categories available',
                inputType: TextInputType.text,
                onPressed: _isFromDraft
                    ? null
                    : () async {
                        if (widget.creatorProfile.categories?.isNotEmpty == true) {
                          await platformSpecificDropdown(
                            context: context,
                            items: widget.creatorProfile.categories
                                    ?.map((category) => category.name ?? "")
                                    .toList() ??
                                [],
                            value: nicheController.text,
                            onChanged: (value) {
                              setState(() {
                                nicheController.text = value ?? "";
                              });
                            },
                            key: nicheKey,
                          );

                          selectedNiche = widget.creatorProfile.categories
                              ?.firstWhere((category) => category.name == nicheController.text);
                        }
                      },
                readOnly: true,
                suffixIcon: _isFromDraft
                    ? null
                    : const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.body,
                        size: 18,
                      ),
                validator: validateGeneric,
              ),
              12.0.height,

              GuardedShowcase(
                showcaseKey: TourKeys.bookingFormDescription,
                description: 'Describe the job clearly to avoid revisions.',
                targetBorderRadius: BorderRadius.circular(8),
                child: TextInputField(
                  header: 'Describe Job',
                  controller: jobDescriptionController,
                  hint: 'Enter description here',
                  inputType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 4,
                  validator: validateGeneric,
                ),
              ),
              12.0.height,
              GuardedShowcase(
                showcaseKey: TourKeys.bookingFormDetails,
                description: 'Set date, time, duration, price, and location (if in-person).',
                targetBorderRadius: BorderRadius.circular(8),
                child: TextInputField(
                  key: workModeKey,
                  header: 'Work Mode',
                  controller: workModeController,
                  hint: 'Select',
                  inputType: TextInputType.text,
                  onPressed: () async {
                    await platformSpecificDropdown(
                      context: context,
                      items: ['Remote', 'On-site', 'Hybrid'],
                      value: workModeController.text,
                      onChanged: (value) {
                        workModeController.text = value!;
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
              ),
              12.0.height,
              TextInputField(
                header: 'Start Date',
                controller: startDateController,
                hint: 'Select Start Date',
                inputType: TextInputType.text,
                onPressed: () async {
                  selectedStartDate = await AppBottomSheet.showBottomSheet(
                    context,
                    widget: CreatorUnavailabliitySheet(
                      widget.creatorProfile.id ?? '',
                      excludeToday: selectedTypeOfBooking == 'deliverable-based',
                    ),
                  );

                  if (selectedStartDate != null) {
                    startDateController.text =
                        selectedStartDate!.unavailableDate!.toFormattedDateWithYear();
                  } else {
                    startDateController.clear();
                  }
                  setState(() {});
                },
                readOnly: true,
                suffixIcon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.body,
                  size: 18,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Field cannot be Empty';
                  }
                  // For Deliverable Based, ensure selected date is not today
                  else if (selectedTypeOfBooking == 'deliverable-based' &&
                      selectedStartDate != null &&
                      selectedStartDate!.unavailableDate!.isAtSameDateAs(DateTime.now())) {
                    return 'Start date cannot be today';
                  }

                  return null;
                },
              ),

              // Time Based Fields
              if (selectedTypeOfBooking == 'time-based') ...[
                if (selectedStartDate != null &&
                    (selectedStartDate!.startTime != null) &&
                    (selectedStartDate!.endTime != null)) ...[
                  8.0.height,
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppImages.infoCircle,
                        width: 18,
                        height: 18,
                        colorFilter: AppColors.highlightCoral.colorFilterMode(),
                      ),
                      6.0.width,
                      Flexible(
                        child: RichText(
                          text: TextSpan(
                            text: "${widget.creatorProfile.name} will be UNAVAILABLE from ",
                            style: context.textTheme.bodySmall,
                            children: [
                              TextSpan(
                                text: selectedStartDate?.startTime?.toBookingTime(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.highlightCoral,
                                    ),
                              ),
                              const TextSpan(
                                text: ' to ',
                              ),
                              TextSpan(
                                text: selectedStartDate?.endTime?.toBookingTime(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.highlightCoral,
                                    ),
                              ),
                              const TextSpan(
                                text: ' on the selected start date.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                12.0.height,
                TextInputField(
                  header: 'Start Time',
                  controller: startTimeController,
                  hint: 'Select Start Time',
                  inputType: TextInputType.text,
                  onPressed: () async {
                    final time = await showPlatformTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (time != null) {
                      if (context.mounted) {
                        startTimeController.text = time.format(context);
                        selectedStartTime = time;
                      }

                      setState(() {});
                    }
                  },
                  readOnly: true,
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.body,
                    size: 18,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Field cannot be Empty';
                    }
                    log(value);
                    if (selectedStartDate != null && selectedStartTime != null) {
                      final unavailableStartTime = selectedStartDate!.startTime;
                      final unavailableEndTime = selectedStartDate!.endTime;

                      // Check if the Value is within the unavailable time range
                      if (unavailableStartTime != null && unavailableEndTime != null) {
                        // Parse the time strings (format: "HH:MM:SS")
                        final startTimeParts = unavailableStartTime.split(':');
                        final endTimeParts = unavailableEndTime.split(':');

                        if (startTimeParts.length >= 2 && endTimeParts.length >= 2) {
                          final selectedDateTime = DateTime(
                            selectedStartDate!.unavailableDate!.year,
                            selectedStartDate!.unavailableDate!.month,
                            selectedStartDate!.unavailableDate!.day,
                            selectedStartTime!.hour,
                            selectedStartTime!.minute,
                          );

                          final startDateTime = DateTime(
                            selectedStartDate!.unavailableDate!.year,
                            selectedStartDate!.unavailableDate!.month,
                            selectedStartDate!.unavailableDate!.day,
                            int.parse(startTimeParts[0]),
                            int.parse(startTimeParts[1]),
                          );

                          final endDateTime = DateTime(
                            selectedStartDate!.unavailableDate!.year,
                            selectedStartDate!.unavailableDate!.month,
                            selectedStartDate!.unavailableDate!.day,
                            int.parse(endTimeParts[0]),
                            int.parse(endTimeParts[1]),
                          );

                          if ((selectedDateTime.isAfter(startDateTime) ||
                                  selectedDateTime.isAtSameMomentAs(startDateTime)) &&
                              (selectedDateTime.isBefore(endDateTime) ||
                                  selectedDateTime.isAtSameMomentAs(endDateTime))) {
                            return "Selected time is within the creator's unavailable time range";
                          }
                        }
                      }

                      // If the start date is today, ensure the selected time is not in the past
                      final now = DateTime.now();
                      if (selectedStartDate!.unavailableDate != null &&
                          selectedStartDate!.unavailableDate!
                              .isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
                        final selectedDateTime = DateTime(
                          selectedStartDate!.unavailableDate!.year,
                          selectedStartDate!.unavailableDate!.month,
                          selectedStartDate!.unavailableDate!.day,
                          selectedStartTime!.hour,
                          selectedStartTime!.minute,
                        );

                        if (selectedDateTime.isBefore(now)) {
                          return "Selected time cannot be in the past";
                        }
                      }
                    }
                    return null;
                  },
                ),
              ],
              12.0.height,
              Row(
                children: [
                  Expanded(
                    child: TextInputField(
                      header: 'Duration',
                      controller: durationController,
                      hint: 'Enter',
                      inputType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2)
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty || int.parse(value) == 0) {
                          return 'This field is required';
                        } else if ((selectedTypeOfBooking == 'time-based') &&
                            int.parse(value) > 24) {
                          return 'Cannot exceed 24 hours for time-based bookings';
                        }
                        return null;
                      },
                    ),
                  ),
                  12.0.width,
                  Expanded(
                    child: TextInputField(
                      key: unitKey,
                      header: 'Unit',
                      controller: unitController,
                      hint: 'Select',
                      inputType: TextInputType.text,
                      onPressed: selectedTypeOfBooking == 'time-based'
                          ? null
                          : () async {
                              await platformSpecificDropdown(
                                context: context,
                                items: [
                                  if (selectedTypeOfBooking == 'time-based') ...[
                                    'hours',
                                  ] else ...[
                                    'days',
                                    'weeks',
                                    'months',
                                    'years',
                                  ],
                                ],
                                value: unitController.text,
                                onChanged: (value) {
                                  unitController.text = value!;
                                },
                                key: unitKey,
                              );
                            },
                      readOnly: true,
                      suffixIcon: selectedTypeOfBooking == 'time-based'
                          ? null
                          : const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.body,
                              size: 18,
                            ),
                      validator: validateGeneric,
                    ),
                  ),
                ],
              ),
              12.0.height,
              TextInputField(
                header:
                    'Location ${workModeController.text.toLowerCase() == 'remote' ? '(Optional)' : ''}',
                controller: locationController,
                hint: 'Enter Location',
                inputType: TextInputType.text,
                validator:
                    workModeController.text.toLowerCase() == 'remote' ? null : validateGeneric,
              ),

              // Time Based Fields
              if (selectedTypeOfBooking == 'time-based') ...[
                12.0.height,
                NumberInputField(
                  header: 'Price',
                  headerInfo:
                      'This price is shown in the creator\'s currency (${widget.creatorProfile.primaryCurrency})',
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    LengthLimitingTextInputFormatter(17),
                    ThousandsFormatter(
                      allowFraction: true,
                      formatter: NumberFormat.decimalPattern(),
                    ),
                  ],
                  onChanged: (value) {
                    num val = num.tryParse(value.replaceAll(',', '')) ?? 0;
                    if (val != 0) {
                      num exchangeRate = widget.creatorProfile.exchangeRateInfo?.rate ?? 0;
                      num equivalentPrice = val * exchangeRate;
                      equivalentPriceController.text = equivalentPrice.toString();
                    } else {
                      equivalentPriceController.clear();
                    }
                  },
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.heading,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: "${widget.creatorProfile.primaryCurrency} ",
                    prefixStyle: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    hintStyle: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.body,
                    ),
                  ),
                ),

                // Equivalent Price
                if (userData.primaryCurrency != null &&
                    widget.creatorProfile.primaryCurrency != userData.primaryCurrency) ...[
                  ListenableBuilder(
                      listenable: priceController,
                      builder: (context, val) {
                        return priceController.text.trim().isEmpty
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  "≈ ${num.tryParse(equivalentPriceController.text.removeCommas())?.amountWithCurrency(userData.primaryCurrency ?? '') ?? 0.amountWithCurrency(userData.primaryCurrency ?? '')}",
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.subHeading,
                                  ),
                                ),
                              );
                      })
                ],
              ],

              if (selectedTypeOfBooking == 'deliverable-based') ...[
                20.0.height,
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Set Deliverables",
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.subHeading,
                      height: 1.5,
                    ),
                  ),
                ),
                18.0.height,

                // Dynamic Deliverable Cards
                ...deliverableCards.asMap().entries.map((entry) {
                  int index = entry.key;
                  DeliverableCardData card = entry.value;

                  return Column(
                    children: [
                      _buildDeliverableCard(card, index, userData),
                      12.0.height,
                    ],
                  );
                }),

                // Add Button
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _canAddDeliverable ? _addDeliverableCard : null,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _canAddDeliverable ? AppColors.highlightCoral : AppColors.grey300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: _canAddDeliverable ? Colors.white : AppColors.body,
                            size: 14,
                          ),
                          4.0.width,
                          Text(
                            "Add",
                            style: context.textTheme.bodySmall?.copyWith(
                              color: _canAddDeliverable ? Colors.white : AppColors.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Total Price
                16.0.height,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TransactionLine(
                    title: 'Total Price',
                    titleSize: 14,
                    valueColor: AppColors.highlightGreen,
                    value: (num.tryParse(priceController.text.replaceAll(',', '')) ?? 0)
                        .amountWithCurrency(widget.creatorProfile.primaryCurrency ?? ''),
                    valueSize: 14,
                  ),
                ),

                // Equivalent Total Price
                if (userData.primaryCurrency != null &&
                    widget.creatorProfile.primaryCurrency != userData.primaryCurrency) ...[
                  ListenableBuilder(
                    listenable: priceController,
                    builder: (context, _) {
                      final rawTotal =
                          num.tryParse(priceController.text.replaceAll(',', '').trim());
                      if (rawTotal == null || rawTotal == 0) {
                        return const SizedBox.shrink();
                      }
                      final exchangeRate = widget.creatorProfile.exchangeRateInfo?.rate ?? 0;
                      final equivalentTotal = rawTotal * exchangeRate;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "≈ ${equivalentTotal.amountWithCurrency(userData.primaryCurrency ?? '')}",
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.subHeading,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
              24.0.height,

              // Accept Terms and Conditions
              Row(
                children: [
                  Checkbox(
                    value: acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        acceptTerms = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  6.0.width,
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "By booking, you agree to Creatify's ",
                        style: context.textTheme.bodySmall,
                        children: [
                          TextSpan(
                            text: 'Terms & Conditions',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.push(
                                  const WebviewScreen(
                                    url: Constants.termsAndConditionsUrl,
                                    routeName: 'Terms and Conditions',
                                  ),
                                );
                              },
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.highlightCoral,
                                ),
                          ),
                          const TextSpan(
                            text: ' and ',
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.push(
                                  const WebviewScreen(
                                    url: Constants.privacyPolicyUrl,
                                    routeName: 'Privacy Policy',
                                  ),
                                );
                              },
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.highlightCoral,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
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
              Row(
                children: [
                  // MARK: Save Draft Button
                  Expanded(
                    child: ListenableBuilder(
                      listenable: Listenable.merge([
                        nicheController,
                      ]),
                      builder: (context, _) {
                        bool isBookingValid = validateRequiredFields([
                          nicheController.text,
                          selectedTypeOfBooking,
                        ]);

                        return MainButton(
                          text: 'Save as Draft',
                          color: AppColors.orange,
                          isLoading: draftBookingLoading,
                          onPressed: isBookingValid
                              ? () {
                                  bool isTimeBased = selectedTypeOfBooking == 'time-based';

                                  ref.read(saveDraftBookingProvider.notifier).saveDraftBooking(
                                        BookCreatorReq(
                                          creatorName: widget.creatorProfile.name ?? '',
                                          creatorId: widget.creatorProfile.id ?? '',
                                          creatorCategory: widget.creatorProfile.categories
                                                  ?.firstWhere((category) =>
                                                      category.id == selectedNiche?.id)
                                                  .name ??
                                              '',
                                          bookingType: selectedTypeOfBooking,
                                          jobDescription: jobDescriptionController.text.trim(),
                                          creatorCategoryId: selectedNiche?.id ?? '',
                                          workMode: workModeController.text.toLowerCase().trim(),
                                          startDate: selectedStartDate?.unavailableDate,
                                          startTime: isTimeBased
                                              ? selectedStartTime?.to24HourFormat()
                                              : null,
                                          duration: durationController.text.isEmpty
                                              ? null
                                              : "${durationController.text.trim()}${unitController.text.trim()}",
                                          location: locationController.text.trim(),
                                          deliverables: isTimeBased ? null : deliverables,
                                          price: priceController.text.isEmpty
                                              ? null
                                              : num.parse(
                                                  priceController.text.replaceAll(',', '').trim(),
                                                ),
                                        ),
                                      );
                                }
                              : null,
                        );
                      },
                    ),
                  ),
                  12.0.width,

                  // MARK: Send Offer Button
                  Expanded(
                    child: ListenableBuilder(
                      listenable: Listenable.merge([
                        jobDescriptionController,
                        nicheController,
                        workModeController,
                        startDateController,
                        startTimeController,
                        durationController,
                        unitController,
                        locationController,
                        priceController,
                        ...deliverableCards.expand((card) => [
                              card.descriptionController,
                              card.priceController,
                            ]),
                      ]),
                      builder: (context, _) {
                        bool isBookingValid = validateRequiredFields([
                              jobDescriptionController.text,
                              nicheController.text,
                              workModeController.text,
                              startDateController.text,
                              durationController.text,
                              unitController.text,
                              workModeController.text.toLowerCase() == 'remote'
                                  ? 'Optional'
                                  : locationController.text,
                              if (selectedTypeOfBooking == 'time-based') ...[
                                startTimeController.text,
                                priceController.text,
                              ],
                              if (selectedTypeOfBooking == 'deliverable-based') ...[
                                if (deliverables.isEmpty) '' else 'Valid',
                              ],
                            ]) &&
                            (selectedTypeOfBooking == 'time-based'
                                ? int.parse(durationController.text) <= 24
                                : true) &&
                            (selectedStartDate != null &&
                                (selectedTypeOfBooking == 'time-based' ||
                                    !selectedStartDate!.unavailableDate!
                                        .isAtSameDateAs(DateTime.now())));

                        // bool isTimeBasedValid = validateRequiredFields([
                        //       jobDescriptionController.text,
                        //       nicheController.text,
                        //       workModeController.text,
                        //       startDateController.text,
                        //       durationController.text,
                        //       unitController.text,
                        //       workModeController.text.toLowerCase() == 'remote'
                        //           ? 'Optional'
                        //           : locationController.text,
                        //       startTimeController.text,
                        //       priceController.text,
                        //     ]) &&
                        //     int.parse(durationController.text) <= 24;

                        // bool isDeliveryBasedValid = validateRequiredFields([
                        //       jobDescriptionController.text,
                        //       nicheController.text,
                        //       workModeController.text,
                        //       startDateController.text,
                        //       durationController.text,
                        //       unitController.text,
                        //       workModeController.text.toLowerCase() == 'remote'
                        //           ? 'Optional'
                        //           : locationController.text,
                        //     ]) &&
                        //     deliverables.isNotEmpty &&
                        //     (selectedStartDate != null &&
                        //         !selectedStartDate!.unavailableDate!
                        //             .isAtSameDateAs(DateTime.now()));

                        return MainButton(
                          text: 'Send Offer',
                          isLoading: bookingCreatorLoading,
                          onPressed: isBookingValid && acceptTerms
                              ? () {
                                  bool isTimeBased = selectedTypeOfBooking == 'time-based';

                                  ref
                                      .read(deliveryBasedCreatorBookingProvider.notifier)
                                      .bookCreator(
                                        BookCreatorReq(
                                          creatorName: widget.creatorProfile.name ?? '',
                                          creatorId: widget.creatorProfile.id ?? '',
                                          creatorCategory: widget.creatorProfile.categories
                                                  ?.firstWhere((category) =>
                                                      category.id == selectedNiche?.id)
                                                  .name ??
                                              '',
                                          bookingType: selectedTypeOfBooking,
                                          jobDescription: jobDescriptionController.text.trim(),
                                          creatorCategoryId: selectedNiche?.id ?? '',
                                          workMode: workModeController.text.toLowerCase().trim(),
                                          startDate: selectedStartDate?.unavailableDate,
                                          startTime: isTimeBased
                                              ? selectedStartTime?.to24HourFormat()
                                              : null,
                                          duration:
                                              "${durationController.text.trim()}${unitController.text.trim()}",
                                          location: locationController.text.trim(),
                                          deliverables: isTimeBased ? null : deliverables,
                                          price: num.parse(
                                            priceController.text.replaceAll(',', '').trim(),
                                          ),
                                        ),
                                      );
                                }
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
              12.0.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliverableCard(DeliverableCardData card, int index, UserDto userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Delivery ${index + 1}",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.subHeading,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (deliverableCards.length > 1)
              GestureDetector(
                onTap: () => _removeDeliverableCard(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
          ],
        ),
        6.0.height,
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.grey300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                autocorrect: true,
                controller: card.descriptionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  _updateDeliverables();
                  setState(() {}); // Refresh UI to update add button state
                },
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.subHeading,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter Deliverable',
                  hintStyle: TextStyle(
                    color: AppColors.body,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              12.0.height,
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.4,
                  child: NumberInputField(
                    controller: card.priceController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _updateDeliverables();
                      _calculateTotalPrice();
                      setState(() {}); // Refresh UI to update add button state
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      LengthLimitingTextInputFormatter(17),
                      ThousandsFormatter(
                        allowFraction: true,
                        formatter: NumberFormat.decimalPattern(),
                      ),
                    ],
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.subHeading,
                    ),
                    decoration: InputDecoration(
                      fillColor: AppColors.grey50,
                      hintText: '0.00',
                      prefixText: "${widget.creatorProfile.primaryCurrency} ",
                      prefixStyle: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      hintStyle: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.body,
                      ),
                      contentPadding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),

              // Equivalent Price for individual deliverable
              if (userData.primaryCurrency != null &&
                  widget.creatorProfile.primaryCurrency != userData.primaryCurrency) ...[
                ListenableBuilder(
                  listenable: card.priceController,
                  builder: (context, _) {
                    final rawPrice =
                        num.tryParse(card.priceController.text.replaceAll(',', '').trim());
                    if (rawPrice == null || rawPrice == 0) {
                      return const SizedBox.shrink();
                    }
                    final exchangeRate = widget.creatorProfile.exchangeRateInfo?.rate ?? 0;
                    final equivalentPrice = rawPrice * exchangeRate;
                    final userData = ref.read(userControllerProvider);
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          "≈ ${equivalentPrice.amountWithCurrency(userData.primaryCurrency ?? '')}",
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.subHeading,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// Helper class to manage deliverable card data
class DeliverableCardData {
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final String id;

  DeliverableCardData({
    required this.id,
  })  : descriptionController = TextEditingController(),
        priceController = TextEditingController();

  void dispose() {
    descriptionController.dispose();
    priceController.dispose();
  }

  bool get isValid =>
      descriptionController.text.trim().isNotEmpty && priceController.text.trim().isNotEmpty;

  Deliverable toDeliverable() {
    return Deliverable(
      description: descriptionController.text.trim(),
      price: num.tryParse(priceController.text.replaceAll(',', '').trim()) ?? 0,
    );
  }
}
