import 'package:creatify_mobile/data/models/requests/update_availability_req.dart' as update_req;
import 'package:creatify_mobile/data/models/responses/creator_availabiity_dto.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/update_work_mode_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/update_availability_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/widgets/availability_calendar_widget.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/widgets/set_availability_bottom_sheet.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EditAvailabilitySheet extends ConsumerStatefulWidget {
  const EditAvailabilitySheet({super.key});

  @override
  ConsumerState<EditAvailabilitySheet> createState() => _EditAvailabilitySheetState();
}

class _EditAvailabilitySheetState extends ConsumerState<EditAvailabilitySheet> {
  List<update_req.UnavailableDate> unavailableDates = [];
  List<String> unavailableMonths = [];
  List<String> unblockedMonths = []; // Track months that were unblocked
  DateTime currentMonth = DateTime.now();
  bool _isInitialized = false;

  WorkPreference? initialWorkPreference;

  // Convert server unavailable dates to local format
  void _initializeFromServerData(List<UnavailableDate> serverDates) {
    if (_isInitialized) return;

    unavailableDates = serverDates
        .where((date) => date.isMonthBlock != 1) // Exclude month blocks
        .map((date) => update_req.UnavailableDate(
              date: date.unavailableDate,
              isFullDay: date.isFullDay,
              startTime: date.startTime?.toShortTime(),
              endTime: date.endTime?.toShortTime(),
              reason: date.reason,
            ))
        .toList();

    // Extract unique month-year values for month blocks
    unavailableMonths = serverDates
        .where((date) => date.isMonthBlock == 1 && date.monthYear != null)
        .map((date) => date.monthYear!)
        .toSet()
        .toList();

    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final getAvailability =
        ref.watch(fetchAvailabilityProvider((currentMonth.year, currentMonth.month)));
    final updatingAvailability = ref.watch(updateAvailabilityProvider).isLoading;

    ref.listen(updateAvailabilityProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();
        ToastDialog.showSuccess('Your Availability has been Updated', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  12.0.height,
                  // MARK: Title
                  Row(
                    children: [
                      Text(
                        'Manage Availability',
                        style: context.textTheme.headlineSmall?.copyWith(fontSize: 23),
                      ),
                      6.0.width,
                      SvgPicture.asset(
                        AppImages.calendarLine,
                      )
                    ],
                  ),
                  6.0.height,
                  Text(
                    "Keep your calendar up to date so recruiters know when you're available. Mark days as fully available, partially unavailable, or fully unavailable",
                    style: context.textTheme.bodySmall,
                  ),
                  32.0.height,

                  // MARK: Availability Calendar
                  getAvailability.when(
                    data: (availability) {
                      initialWorkPreference ??= availability.workPreference;

                      // Initialize unavailable dates from server data on first load
                      _initializeFromServerData(availability.unavailableDates ?? []);

                      return AvailabilityCalendarWidget(
                        selectedMonth: currentMonth,
                        serverUnavailableDates: availability.unavailableDates ?? [],
                        localUnavailableDates: unavailableDates,
                        unavailableMonths: unavailableMonths,
                        unblockedMonths: unblockedMonths,
                        onDateSelected: _handleDateSelection,
                        onMonthChanged: _handleMonthChange,
                        onMonthToggled: _handleMonthToggle,
                      );
                    },
                    loading: () => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Loading Availability...'),
                          8.0.height,
                          const CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    error: (error, _) => Center(
                      child: Text(
                        'Error loading availability: $error',
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          12.0.height,
          ListenableBuilder(
            listenable: Listenable.merge([]),
            builder: (context, child) {
              return MainButton(
                text: 'Save & Continue',
                isLoading: updatingAvailability,
                onPressed: () async {
                  if (getAvailability.hasValue) {
                    update_req.UpdateAvailabilityReq? availabilityReq =
                        await AppBottomSheet.showBottomSheet(
                      context,
                      widget: UpdateWorkModeSheet(
                        workPreference: initialWorkPreference,
                      ),
                    );

                    if (availabilityReq != null) {
                      ref.read(updateAvailabilityProvider.notifier).updateAvailability(
                            availabilityReq.copyWith(
                              unavailableDates: unavailableDates,
                              unavailableMonths: unavailableMonths,
                            ),
                          );
                    }
                  }
                },
              );
            },
          ),
          12.0.height,
        ],
      ),
    );
  }

  void _handleDateSelection(DateTime selectedDate) async {
    // Check if the month is currently blocked
    final monthYear = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}';
    final isMonthBlocked = unavailableMonths.contains(monthYear);

    // If the month is blocked, unblock it and remove all dates from that month
    if (isMonthBlocked) {
      setState(() {
        // Remove the month from blocked months
        unavailableMonths.remove(monthYear);

        // Track that this month was explicitly unblocked
        if (!unblockedMonths.contains(monthYear)) {
          unblockedMonths.add(monthYear);
        }

        // Remove all unavailable dates from that month
        unavailableDates.removeWhere((date) {
          if (date.date == null) return false;
          final dateMonthYear = '${date.date!.year}-${date.date!.month.toString().padLeft(2, '0')}';
          return dateMonthYear == monthYear;
        });
      });

      // Now show the bottom sheet to let user mark this specific date
      final result = await AppBottomSheet.showBottomSheet(
        context,
        widget: SetAvailabilityBottomSheet(
          selectedDate: selectedDate,
          existingUnavailableDate: null,
        ),
      );

      if (result is update_req.UnavailableDate) {
        setState(() {
          unavailableDates.add(result);
        });
      }
      return;
    }

    // Check if there's an existing unavailable date for this day
    update_req.UnavailableDate? existingLocalDate;

    try {
      existingLocalDate = unavailableDates.firstWhere(
        (date) => date.date != null && _isSameDate(date.date!, selectedDate),
      );
    } catch (e) {
      existingLocalDate = null;
    }

    final result = await AppBottomSheet.showBottomSheet(
      context,
      widget: SetAvailabilityBottomSheet(
        selectedDate: selectedDate,
        existingUnavailableDate: existingLocalDate,
      ),
    );

    if (result == 'delete') {
      // Remove the unavailable date
      setState(() {
        unavailableDates
            .removeWhere((date) => date.date != null && _isSameDate(date.date!, selectedDate));
      });
    } else if (result is update_req.UnavailableDate) {
      setState(() {
        // Remove any existing unavailable date for the same day
        unavailableDates.removeWhere((date) =>
            date.date != null && result.date != null && _isSameDate(date.date!, result.date!));

        // Add the new unavailable date
        unavailableDates.add(result);
      });
    }
  }

  void _handleMonthToggle(String monthYear, bool isBlocked) {
    setState(() {
      if (isBlocked) {
        // Add to unavailable months
        if (!unavailableMonths.contains(monthYear)) {
          unavailableMonths.add(monthYear);
        }
        // Remove from unblocked list if re-blocking
        unblockedMonths.remove(monthYear);
      } else {
        // Remove from unavailable months
        unavailableMonths.remove(monthYear);

        // Track that this month was explicitly unblocked
        if (!unblockedMonths.contains(monthYear)) {
          unblockedMonths.add(monthYear);
        }

        // Also remove all dates from that month in unavailableDates
        // This handles server-initialized dates for month blocks
        unavailableDates.removeWhere((date) {
          if (date.date == null) return false;
          final dateMonthYear = '${date.date!.year}-${date.date!.month.toString().padLeft(2, '0')}';
          return dateMonthYear == monthYear;
        });
      }
    });
  }

  void _handleMonthChange(DateTime newMonth) {
    setState(() {
      currentMonth = newMonth;
    });
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}
