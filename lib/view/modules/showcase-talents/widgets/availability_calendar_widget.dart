import 'package:creatify_mobile/data/models/requests/update_availability_req.dart' as update_req;
import 'package:creatify_mobile/data/models/responses/creator_availabiity_dto.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';

class AvailabilityCalendarWidget extends StatefulWidget {
  final DateTime selectedMonth;
  final List<UnavailableDate> serverUnavailableDates;
  final List<update_req.UnavailableDate> localUnavailableDates;
  final List<String> unavailableMonths;
  final List<String> unblockedMonths;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onMonthChanged;
  final Function(String monthYear, bool isBlocked) onMonthToggled;

  const AvailabilityCalendarWidget({
    super.key,
    required this.selectedMonth,
    required this.serverUnavailableDates,
    required this.localUnavailableDates,
    required this.unavailableMonths,
    required this.unblockedMonths,
    required this.onDateSelected,
    required this.onMonthChanged,
    required this.onMonthToggled,
  });

  @override
  State<AvailabilityCalendarWidget> createState() => _AvailabilityCalendarWidgetState();
}

class _AvailabilityCalendarWidgetState extends State<AvailabilityCalendarWidget> {
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
    widget.onMonthChanged(currentMonth);
  }

  bool _isMonthBlocked(DateTime month) {
    final monthYear = '${month.year}-${month.month.toString().padLeft(2, '0')}';

    // If this month was explicitly unblocked, don't consider it blocked
    if (widget.unblockedMonths.contains(monthYear)) {
      return false;
    }

    // Check local unavailable months first
    if (widget.unavailableMonths.contains(monthYear)) {
      return true;
    }

    // Check if server data indicates this month is blocked
    return widget.serverUnavailableDates
        .any((date) => date.isMonthBlock == 1 && date.monthYear == monthYear);
  }

  bool _isDateUnavailable(DateTime date) {
    // Check if the entire month is blocked
    if (_isMonthBlocked(date)) {
      return true;
    }

    // Check local unavailable dates first (priority for user changes)
    final localUnavailable = widget.localUnavailableDates.any((unavailableDate) =>
        unavailableDate.date != null && _isSameDate(unavailableDate.date!, date));

    if (localUnavailable) {
      final localDate = widget.localUnavailableDates.firstWhere(
        (unavailableDate) =>
            unavailableDate.date != null && _isSameDate(unavailableDate.date!, date),
      );
      return localDate.isFullDay == true;
    }

    // Check if this date's month was explicitly unblocked
    final dateMonthYear = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    if (widget.unblockedMonths.contains(dateMonthYear)) {
      return false; // Don't show server dates for unblocked months
    }

    // Fall back to server data
    return widget.serverUnavailableDates.any((unavailableDate) =>
        unavailableDate.unavailableDate != null &&
        _isSameDate(unavailableDate.unavailableDate!, date) &&
        unavailableDate.isFullDay == true);
  }

  bool _isPartiallyUnavailable(DateTime date) {
    // If the entire month is blocked, there are no partially unavailable dates
    if (_isMonthBlocked(date)) {
      return false;
    }

    // Check local unavailable dates first (priority for user changes)
    final localUnavailable = widget.localUnavailableDates.any((unavailableDate) =>
        unavailableDate.date != null && _isSameDate(unavailableDate.date!, date));

    if (localUnavailable) {
      final localDate = widget.localUnavailableDates.firstWhere(
        (unavailableDate) =>
            unavailableDate.date != null && _isSameDate(unavailableDate.date!, date),
      );
      return localDate.isFullDay == false;
    }

    // Check if this date's month was explicitly unblocked
    final dateMonthYear = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    if (widget.unblockedMonths.contains(dateMonthYear)) {
      return false; // Don't show server dates for unblocked months
    }

    // Fall back to server data
    final unavailableDate = widget.serverUnavailableDates.firstWhere(
      (unavailableDate) =>
          unavailableDate.unavailableDate != null &&
          _isSameDate(unavailableDate.unavailableDate!, date),
      orElse: () => UnavailableDate(),
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
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Month navigation header
          _buildMonthHeader(),
          24.0.height,

          // Days of week header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildDaysOfWeekHeader(),
                12.0.height,

                // Calendar grid
                _buildCalendarGrid(),
              ],
            ),
          ),
          12.0.height,

          // Mark Entire Month Unavailable Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Mark Month as Unavailable",
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
                  value: _isMonthBlocked(currentMonth),
                  onChanged: (value) {
                    final monthYear =
                        '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}';
                    widget.onMonthToggled(monthYear, value);
                  },
                ),
              )
            ],
          ),

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

      dayWidgets.add(
        GestureDetector(
          onTap: isPastDate ? null : () => widget.onDateSelected(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _getDayBackgroundColor(
                  isUnavailable, isPartiallyUnavailable, isToday, isPastDate),
              borderRadius: BorderRadius.circular(8),
              border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: context.textTheme.bodyMedium?.copyWith(
                  color:
                      _getDayTextColor(isUnavailable, isPartiallyUnavailable, isToday, isPastDate),
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
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
