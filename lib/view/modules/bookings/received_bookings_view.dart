import 'package:creatify_mobile/data/models/responses/booking_item_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/bookings_card.dart';
import 'package:creatify_mobile/view/modules/onboarding/widgets/search_input_field.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/card_and_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReceivedBookingsView extends ConsumerStatefulWidget {
  final int? length;
  const ReceivedBookingsView({
    super.key,
    this.length,
  });

  @override
  ConsumerState<ReceivedBookingsView> createState() => _ReceivedBookingsViewState();
}

class _ReceivedBookingsViewState extends ConsumerState<ReceivedBookingsView> {
  final searchController = TextEditingController();
  String searchQuery = '';
  BookingStatus? selectedStatus;

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
    });
  }

  void _onStatusFilterChanged(BookingStatus? status) {
    setState(() {
      selectedStatus = status;
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
    final receivedBookings = ref.watch(fetchReceivedBookingsProvider);

    return RefreshIndicator.adaptive(
      edgeOffset: 2,
      backgroundColor: Colors.white,
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(fetchReceivedBookingsProvider);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  receivedBookings.when(
                    data: (bookings) {
                      final filteredBookings = bookings.where((booking) {
                        final clientName = booking.recruiter?.name?.toLowerCase();
                        final matchesSearch = clientName?.contains(searchQuery) ?? false;
                        final matchesStatus =
                            selectedStatus == null || booking.status == selectedStatus;
                        return matchesSearch && matchesStatus;
                      }).toList();

                      return Column(
                        children: [
                          // Show filters only when length it's not on Home View
                          if (widget.length == null) ...[
                            // Status Filters
                            _buildStatusFilters(),
                            12.0.height,
                          ],

                          SearchTextInputField(
                            controller: searchController,
                          ),
                          16.0.height,

                          if (filteredBookings.isEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.only(top: 48.0),
                              child: Center(
                                child: CardAndTextWidget(
                                  text: 'You do not have any active\nbookings yet',
                                  illustration: AppImages.calendarIllustration,
                                ),
                              ),
                            )
                          ] else ...[
                            ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final booking = filteredBookings[index];
                                return BookingsCard(
                                  bookingDetails: booking,
                                  isSent: false,
                                );
                              },
                              separatorBuilder: (context, index) => 12.0.height,
                              itemCount:
                                  widget.length != null && filteredBookings.length < widget.length!
                                      ? filteredBookings.length
                                      : widget.length ?? filteredBookings.length,
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          24.0.height,
                          const CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                          ),
                          8.0.height,
                          const Text('Fetching Bookings...'),
                        ],
                      ),
                    ),
                    error: (error, stackTrace) => Padding(
                      padding: const EdgeInsets.only(top: 48.0),
                      child: Text(
                        "An error occurred while fetching received bookings.".toTitleCase(),
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  24.0.height,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusFilters() {
    final statuses = [
      (null, 'All'),
      (BookingStatus.pending, 'Pending'),
      (BookingStatus.accepted, 'Accepted'),
      (BookingStatus.negotiated, 'Renegotiated'),
      (BookingStatus.completed, 'Completed'),
      (BookingStatus.cancelled, 'Cancelled'),
    ];

    return SizedBox(
      height: 24,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (context, index) => 8.0.width,
        itemBuilder: (context, index) {
          final (status, label) = statuses[index];
          final isSelected = selectedStatus == status;

          return GestureDetector(
            onTap: () => _onStatusFilterChanged(status),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey300,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: isSelected ? Colors.white : AppColors.subHeading,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
