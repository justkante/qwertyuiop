import 'package:creatify_mobile/data/models/responses/unavailability_time_item_dto.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';

class CreatorUnavailabilityCalendarWidget extends StatefulWidget {
  final DateTime selectedMonth;
  final List<CreatorUnavailabilityItemDto> unavailableDates;
  final Function(DateTime) onDateSelected;
  final bool excludeToday;
  // final Function(DateTime) onMonthChanged;

  const CreatorUnavailabilityCalendarWidget({
    super.key,
    required this.selectedMonth,
    required this.unavailableDates,
    required this.onDateSelected,
    this.excludeToday = false,
    //required this.onMonthChanged,
  });

  @override
  State<CreatorUnavailabilityCalendarWidget> createState() =>
      _CreatorUnavailabilityCalendarWidgetState();
}

class _CreatorUnavailabilityCalendarWidgetState extends State<CreatorUnavailabilityCalendarWidget> {
  late DateTime currentMonth;

  @override
  void initState() {
    super.initState();
    currentMonth = widget.selectedMonth;
  }

  void _navigateMonth(bool isNext) {
    setState(() {
      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month + (isNext ? 1 : -1),
        1,
      );
    });
    //widget.onMonthChanged(currentMonth);
  }

  bool _isDateUnavailable(DateTime date) {
    // Fall back to server data
    return widget.unavailableDates.any((unavailableDate) =>
        unavailableDate.unavailableDate != null &&
        _isSameDate(unavailableDate.unavailableDate!, date) &&
        unavailableDate.isFullDay == true);
  }

  bool _isPartiallyUnavailable(DateTime date) {
    // Fall back to server data
    final unavailableDate = widget.unavailableDates.firstWhere(
      (unavailableDate) =>
          unavailableDate.unavailableDate != null &&
          _isSameDate(unavailableDate.unavailableDate!, date),
      orElse: () => CreatorUnavailabilityItemDto(),
    );
    return unavailableDate.unavailableDate != null && unavailableDate.isFullDay == false;
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  List<String> get _monthNames => [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];

  List<String> get _dayNames => ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        //color: AppColors.grey50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        children: [
          // Month navigation header
          _buildMonthHeader(),
          24.0.height,

          // Days of week header
          _buildDaysOfWeekHeader(),
          12.0.height,

          // Calendar grid
          _buildCalendarGrid(),
          24.0.height,

          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _navigateMonth(false),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: AppColors.black2,
              size: 20,
            ),
          ),
        ),
        Text(
          '${_monthNames[currentMonth.month - 1]}, ${currentMonth.year}',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateMonth(true),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.chevron_right,
              color: AppColors.black2,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaysOfWeekHeader() {
    return Row(
      children: _dayNames.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.grey400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    // Get first day of month and calculate starting position
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    // Add empty cells for days before month starts
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      final isToday = _isSameDate(date, DateTime.now());
      final isUnavailable = _isDateUnavailable(date);
      final isPartiallyUnavailable = _isPartiallyUnavailable(date);
      final isPastDate = date.isBefore(DateTime.now()) && !isToday;
      final isTodayExcluded = widget.excludeToday && isToday;

      dayWidgets.add(
        GestureDetector(
          onTap: (isPastDate || isUnavailable || isTodayExcluded)
              ? null
              : () => widget.onDateSelected(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _getDayBackgroundColor(isUnavailable, isPartiallyUnavailable,
                  isToday && !isTodayExcluded, isPastDate || isTodayExcluded),
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isTodayExcluded
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: _getDayTextColor(isUnavailable, isPartiallyUnavailable,
                      isToday && !isTodayExcluded, isPastDate || isTodayExcluded),
                  fontWeight: isToday && !isTodayExcluded ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 7,
      childAspectRatio: 1,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  Color _getDayBackgroundColor(
      bool isUnavailable, bool isPartiallyUnavailable, bool isToday, bool isPastDate) {
    if (isPastDate) return AppColors.grey100;
    if (isUnavailable) return AppColors.highlightRed;
    if (isPartiallyUnavailable) return AppColors.highlightBlue;
    if (isToday) return Colors.transparent;
    return Colors.transparent;
  }

  Color _getDayTextColor(
      bool isUnavailable, bool isPartiallyUnavailable, bool isToday, bool isPastDate) {
    if (isPastDate) return AppColors.grey400;
    if (isUnavailable) return AppColors.highlightRed50;
    if (isPartiallyUnavailable) return AppColors.highlightBlue50;
    if (isToday) return AppColors.primary;
    return AppColors.black2;
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key',
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black2,
          ),
        ),
        12.0.height,
        Row(
          children: [
            _buildLegendItem(
              color: AppColors.highlightRed,
              label: 'Fully Unavailable',
            ),
            24.0.width,
            _buildLegendItem(
              color: AppColors.highlightBlue,
              label: 'Partially Unavailable',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 1),
          ),
        ),
        8.0.width,
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: AppColors.black2,
          ),
        ),
      ],
    );
  }
}
