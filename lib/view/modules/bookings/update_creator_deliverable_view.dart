import 'package:creatify_mobile/view/modules/bookings/sheets/update_status_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/update_booking_status_vm.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/overlay_animation.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:creatify_mobile/core/services/tour_service.dart';
import 'package:creatify_mobile/view/utils/tour/guarded_showcase.dart';
import 'package:creatify_mobile/view/utils/tour/tour_keys.dart';

class UpdateCreatorDeliverableSheet extends ConsumerStatefulWidget {
  final String bookingId;
  const UpdateCreatorDeliverableSheet({
    super.key,
    required this.bookingId,
  });

  @override
  ConsumerState<UpdateCreatorDeliverableSheet> createState() =>
      _UpdateCreatorDeliverableSheetState();
}

class _UpdateCreatorDeliverableSheetState extends ConsumerState<UpdateCreatorDeliverableSheet> {
  bool _tourStarted = false;
  late final ShowcaseView _showcaseView;

  @override
  void initState() {
    super.initState();
    _showcaseView = ShowcaseView.register(
      scope: 'update-deliverable',
      onFinish: () => TourService.markScreenDone(TourService.deliverables),
    );
    _tourStarted = !TourService.shouldShowScreenTour(TourService.deliverables);
  }

  @override
  void dispose() {
    _showcaseView.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deliverables = ref.watch(fetchBookingDeliverablesProvider(widget.bookingId));

    ref.listen(updateCreatorDeliverableStatusProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('Deliverable status updated successfully', context);
      } else if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    if (!_tourStarted) {
      _tourStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showcaseView.startShowCase([
          TourKeys.deliverablesList,
        ]);
      });
    }

    return OverlayLoadingIndicator(
      isLoading: ref.watch(updateCreatorBookingStatusProvider).isLoading,
      text: 'Updating Status...',
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Update Deliverable Status',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.subHeading,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    12.0.height,
                    SvgPicture.asset(
                      AppImages.markCompleted,
                      width: 115,
                      height: 80,
                    ),
                    16.0.height,

                    // MARK: Title

                    Text(
                      "These are your deliverables for this project. Update each status as you work, and mark as Complete when finished. The recruiter will be notified to review.",
                      style: context.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    20.0.height,

                    // Deliverables List
                    GuardedShowcase(
                      showcaseKey: TourKeys.deliverablesList,
                      description:
                          'Track deliverable progress, mark items complete, and notify the recruiter.',
                      targetBorderRadius: BorderRadius.circular(8),
                      child: deliverables.when(
                        data: (data) {
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: data.length,
                            separatorBuilder: (context, index) => 12.0.height,
                            itemBuilder: (context, index) {
                              final deliverable = data[index];
                              return InkWell(
                                onTap: (deliverable.isCompleted != true)
                                    ? () async {
                                        String result = await AppBottomSheet.showBottomSheet(
                                          context,
                                          widget: UpdateDeliverableStatusSheet(
                                            deliverable: deliverable.description,
                                            status: deliverable.status
                                                    ?.replaceAll('_', ' ')
                                                    .toTitleCase() ??
                                                '',
                                          ),
                                        );

                                        if (result.isNotEmpty) {
                                          ref
                                              .read(updateCreatorDeliverableStatusProvider.notifier)
                                              .updateDeliverableBookingStatus(
                                                bookingId: widget.bookingId,
                                                deliverableId: deliverable.id ?? '',
                                                status: result.toLowerCase().replaceAll(' ', '_'),
                                              );
                                        }
                                      }
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: deliverable.isCompleted == true
                                        ? AppColors.grey50
                                        : AppColors.grey200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Deliverable',
                                              style: context.textTheme.bodySmall?.copyWith(
                                                color: deliverable.isCompleted == true
                                                    ? AppColors.body
                                                    : AppColors.subHeading,
                                                decoration: deliverable.isCompleted == true
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                decorationColor: AppColors.body,
                                              ),
                                            ),
                                          ),
                                          4.0.width,
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: switch (deliverable.status) {
                                                'not_started' => AppColors.highlightCoral,
                                                'in_progress' => AppColors.highlightBlue,
                                                'revise' => AppColors.highlightYellow,
                                                'completed' => AppColors.highlightGreen,
                                                '' || _ => AppColors.highlightCoral,
                                              },
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              deliverable.status
                                                      ?.replaceAll('_', ' ')
                                                      .toTitleCase() ??
                                                  '',
                                              style: context.textTheme.bodySmall?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      8.0.height,
                                      Text(
                                        deliverable.description ?? '',
                                        style: context.textTheme.bodyMedium?.copyWith(
                                          color: deliverable.isCompleted == true
                                              ? AppColors.body.withValues(alpha: 0.5)
                                              : AppColors.body,
                                          decoration: deliverable.isCompleted == true
                                              ? TextDecoration.lineThrough
                                              : null,
                                          decorationColor: AppColors.body.withValues(alpha: 0.5),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        error: (error, _) => Center(
                          child: Text(
                            'Failed to load deliverables ${kDebugMode ? error.toString() : ''}',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.subHeading,
                            ),
                          ),
                        ),
                        loading: () => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              24.0.height,
                              const CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                              ),
                              8.0.height,
                              const Text('Loading Deliverables...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            18.0.height,
          ],
        ),
      ),
    );
  }
}
