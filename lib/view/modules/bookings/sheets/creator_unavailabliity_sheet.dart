import 'package:creatify_mobile/data/models/responses/unavailability_time_item_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/unavailability_calendar_widget.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CreatorUnavailabliitySheet extends ConsumerStatefulWidget {
  final String creatorId;
  final bool excludeToday;
  const CreatorUnavailabliitySheet(this.creatorId, {super.key, this.excludeToday = false});

  @override
  ConsumerState<CreatorUnavailabliitySheet> createState() => _CreatorUnavailabliitySheetState();
}

class _CreatorUnavailabliitySheetState extends ConsumerState<CreatorUnavailabliitySheet> {
  @override
  Widget build(BuildContext context) {
    final unavailability = ref.watch(creatorUnavailabilityProvider(widget.creatorId));

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.65,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          12.0.height,

          // MARK: Title
          Text(
            'Select a Date for Booking',
            style: context.textTheme.headlineSmall?.copyWith(fontSize: 18),
          ),
          21.0.height,

          // Calendar
          unavailability.when(
            data: (data) {
              return CreatorUnavailabilityCalendarWidget(
                selectedMonth: DateTime.now(),
                unavailableDates: data,
                excludeToday: widget.excludeToday,
                onDateSelected: (date) {
                  var unavailableDate = data.firstWhere(
                    (unavailableDate) =>
                        unavailableDate.unavailableDate != null &&
                        unavailableDate.unavailableDate!.isAtSameDateAs(date),
                    orElse: () => CreatorUnavailabilityItemDto(
                      unavailableDate: date,
                      isFullDay: false,
                    ),
                  );

                  context.pop(unavailableDate);
                },
              );
            },
            loading: () => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Loading availability...'),
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
          21.0.height,
        ],
      ),
    );
  }
}
