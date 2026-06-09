import 'package:flutter/material.dart';
import 'l10n/strings.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _displayedMonth;
  late DateTime _today;
  late AppStrings _strings;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _displayedMonth = DateTime(_today.year, _today.month, 1);
    _strings = getStrings(WidgetsBinding.instance.platformDispatcher.locale.languageCode);
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

  void _goToToday() {
    setState(() {
      _displayedMonth = DateTime(_today.year, _today.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentMonth = _displayedMonth.month == _today.month &&
        _displayedMonth.year == _today.year;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: month/year navigation ──
            _buildTopBar(isCurrentMonth),

            // ── Giant today display ──
            if (isCurrentMonth) _buildTodayDisplay(),

            // ── Month grid ──
            Expanded(child: _buildMonthGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isCurrentMonth) {
    final monthName = _strings.months[_displayedMonth.month - 1];
    final yearLabel = _strings.yearLabel(_displayedMonth.year);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2962FF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back to today button (house icon)
          if (!isCurrentMonth)
            IconButton(
              icon: const Icon(Icons.today, color: Colors.white, size: 28),
              onPressed: _goToToday,
              tooltip: _strings.today,
            )
          else
            const SizedBox(width: 48),

          const Spacer(),

          // Left arrow
          GestureDetector(
            onTap: _prevMonth,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Icon(Icons.chevron_left, color: Colors.white, size: 36),
            ),
          ),

          // Month + Year
          GestureDetector(
            onTap: isCurrentMonth ? null : _goToToday,
            child: Column(
              children: [
                Text(
                  monthName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  yearLabel,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Right arrow
          GestureDetector(
            onTap: _nextMonth,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Icon(Icons.chevron_right, color: Colors.white, size: 36),
            ),
          ),

          const Spacer(),

          const SizedBox(width: 48), // balance
        ],
      ),
    );
  }

  Widget _buildTodayDisplay() {
    final day = _today.day;
    final weekday = _strings.weekdaysFull[_today.weekday - 1];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Giant day number
          Text(
            '$day',
            style: const TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w800,
              color: Color(0xFFDC322F),
              height: 1.0,
            ),
          ),
          // Day of week
          Text(
            weekday.toUpperCase(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid() {
    final firstDay = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDay = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday % 7; // Sunday = 0

    // Calculate cells needed
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight - 32; // padding
        final rowHeight = availableHeight / (rows + 1); // +1 for header
        final cellHeight = rowHeight.clamp(28.0, 52.0);
        final cellFontSize = cellHeight * 0.4;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              // ── Weekday header row ──
              SizedBox(
                height: cellHeight * 0.8,
                child: Row(
                  children: List.generate(7, (i) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          _strings.weekdaysShort[i],
                          style: TextStyle(
                            fontSize: cellFontSize * 0.85,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Divider(height: 1, thickness: 1),

              // ── Day cells ──
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 0.9,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                  ),
                  itemCount: rows * 7,
                  itemBuilder: (context, index) {
                    final dayNum = index - startWeekday + 1;
                    final isValidDay = dayNum >= 1 && dayNum <= daysInMonth;

                    if (!isValidDay) {
                      return const SizedBox.shrink();
                    }

                    final isToday = isValidDay &&
                        _displayedMonth.month == _today.month &&
                        _displayedMonth.year == _today.year &&
                        dayNum == _today.day;

                    final date = DateTime(
                      _displayedMonth.year, _displayedMonth.month, dayNum,
                    );

                    return _DayCell(
                      day: dayNum,
                      isToday: isToday,
                      isPast: date.isBefore(DateTime(_today.year, _today.month, _today.day + 1)),
                      fontSize: cellFontSize,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isPast;
  final double fontSize;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isPast,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFF2962FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
            color: isToday
                ? Colors.white
                : isPast
                    ? Colors.grey[400]
                    : Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
