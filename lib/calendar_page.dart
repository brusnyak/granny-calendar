import 'package:flutter/material.dart';
import 'l10n/strings.dart';
import 'storage.dart';
import 'event_edit_page.dart';
import 'notifications.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _displayedMonth;
  late DateTime _today;
  DateTime _selectedDate = DateTime.now();
  Map<String, List<CalendarEvent>> _eventsCache = {};

  AppStrings get _s => getStrings(
    WidgetsBinding.instance.platformDispatcher.locale.languageCode,
  );

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedDate = DateTime(_today.year, _today.month, _today.day);
    _displayedMonth = DateTime(_today.year, _today.month, 1);
    _loadMonthEvents();
  }

  Future<void> _loadMonthEvents() async {
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final map = <String, List<CalendarEvent>>{};
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, d);
      final key = _dateKey(date);
      final events = await loadEvents(date);
      if (events.isNotEmpty) map[key] = events;
    }
    // Also load selected date if it falls outside this month
    final selKey = _dateKey(_selectedDate);
    if (!map.containsKey(selKey)) {
      final events = await loadEvents(_selectedDate);
      if (events.isNotEmpty) map[selKey] = events;
    }
    if (mounted) setState(() { _eventsCache = map; });
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _prev() => setState(() {
        _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
        _loadMonthEvents();
      });

  void _next() => setState(() {
        _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
        _loadMonthEvents();
      });

  void _goToday() => setState(() {
        _displayedMonth = DateTime(_today.year, _today.month, 1);
        _selectedDate = DateTime(_today.year, _today.month, _today.day);
        _loadMonthEvents();
      });

  bool get _isCurrentMonth =>
      _displayedMonth.month == _today.month && _displayedMonth.year == _today.year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_isCurrentMonth) _buildHeroDate(),
            _buildWeekdayHeader(),
            Expanded(child: _buildMonthGrid()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        backgroundColor: const Color(0xFF2962FF),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // ─── Drawer ───
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2962FF)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.calendar_month, color: Colors.white, size: 48),
                const SizedBox(height: 8),
                Text(
                  _s.appTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.today),
            title: Text(_s.today),
            onTap: () { Navigator.pop(context); _goToday(); },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(_s.aboutTitle),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(_s.appTitle),
                  content: Text(_s.aboutText),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(_s.ok),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Header: hamburger | month + arrows | + ───
  Widget _buildHeader() {
    final monthName = _s.months[_displayedMonth.month - 1];
    final yearStr = '${_displayedMonth.year}';
    final showToday = !_isCurrentMonth;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.menu_rounded, color: Colors.grey[700], size: 26),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.chevron_left_rounded, color: Colors.grey[600], size: 30),
            onPressed: _prev,
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: showToday ? _goToday : null,
            child: Column(
              children: [
                Text(
                  monthName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1D1F),
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  yearStr,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded, color: Colors.grey[600], size: 30),
            onPressed: _next,
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded,
                color: const Color(0xFF2962FF), size: 26),
            onPressed: _addEvent,
          ),
        ],
      ),
    );
  }

  // ─── Hero date: big blue number, no circle, no white ───
  Widget _buildHeroDate() {
    final day = _today.day;
    final weekday = _s.weekdaysFull[_today.weekday - 1];

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Column(
        children: [
          Text(
            '$day',
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2962FF),
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weekday[0].toUpperCase() + weekday.substring(1),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Weekday headers ───
  Widget _buildWeekdayHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: List.generate(7, (i) {
          final isTodayHeader = _isCurrentMonth && i == (_today.weekday % 7);
          return Expanded(
            child: Center(
              child: Text(
                _s.weekdaysShort[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isTodayHeader
                      ? const Color(0xFF2962FF)
                      : const Color(0xFF8E8E93),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Calendar grid ───
  Widget _buildMonthGrid() {
    final firstDay = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDay = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday % 7;
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: Column(
        children: [
          Container(height: 1, color: const Color(0xFFE5E5EA)),
          const SizedBox(height: 4),
          ...List.generate(rows, (row) {
            return Row(
              children: List.generate(7, (col) {
                final idx = row * 7 + col;
                final dayNum = idx - startWeekday + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox.shrink());
                }
                final date = DateTime(
                  _displayedMonth.year, _displayedMonth.month, dayNum,
                );
                final isToday = _isCurrentMonth && dayNum == _today.day;
                final isSelected =
                    date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;
                final hasEvents = _eventsCache.containsKey(_dateKey(date));

                return Expanded(
                  child: _DayCell(
                    day: dayNum,
                    isToday: isToday,
                    isSelected: isSelected,
                    hasEvents: hasEvents,
                    onTap: () {
                      setState(() => _selectedDate = date);
                      _showDayEvents(date);
                    },
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  // ─── Bottom sheet with events for a day ───
  void _showDayEvents(DateTime date) {
    final events = _eventsCache[_dateKey(date)] ?? [];
    final dateStr = '${date.day} ${_s.months[date.month - 1]} ${date.year}';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: const EdgeInsets.only(top: 8),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D1D1F),
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _addEvent();
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(_s.addEvent),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Events list or empty state
                  if (events.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.event_note, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Text(
                            _s.noEvents,
                            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: events.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1, indent: 44, endIndent: 12,
                        ),
                        itemBuilder: (_, i) {
                          final e = events[i];
                          return ListTile(
                            leading: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2962FF).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: e.time != null
                                  ? Center(
                                      child: Text(
                                        '${e.time!.hour.toString().padLeft(2, '0')}:${e.time!.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2962FF),
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.event, size: 18,
                                      color: Color(0xFF2962FF)),
                            ),
                            title: Text(e.title, style: const TextStyle(fontSize: 16)),
                            subtitle: e.reminder
                                ? Text('🔔 ${_s.reminderOn}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500]))
                                : null,
                            trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                            onTap: () {
                              Navigator.pop(ctx);
                              _editEvent(e);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) => _loadMonthEvents());
  }

  // ─── Add / Edit events ───
  void _addEvent() async {
    final result = await Navigator.of(context).push<CalendarEvent>(
      MaterialPageRoute(
        builder: (_) => EventEditPage(
          selectedDate: _selectedDate,
          s: _s,
        ),
      ),
    );
    if (result == null) return;
    await upsertEvent(_selectedDate, result);
    await scheduleReminder(result);
    _loadMonthEvents();
  }

  void _editEvent(CalendarEvent event) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => EventEditPage(
          event: event,
          selectedDate: _selectedDate,
          s: _s,
        ),
      ),
    );
    if (result == null) return;
    if (result == 'delete') {
      await deleteEvent(_selectedDate, event.id);
      await cancelReminder(event.id);
    } else {
      final updated = result as CalendarEvent;
      final oldId = event.id;
      await upsertEvent(_selectedDate, updated, oldId: oldId);
      await cancelReminder(oldId);
      await scheduleReminder(updated);
    }
    _loadMonthEvents();
  }
}

// ─── Day cell ───
class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final bool hasEvents;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.hasEvents,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width / 7 - 8;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isToday
              ? const Color(0xFF2962FF)
              : isSelected
                  ? const Color(0xFF2962FF).withValues(alpha: 0.12)
                  : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: size * 0.38,
                fontWeight: isToday || isSelected
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: isToday
                    ? Colors.white
                    : isSelected
                        ? const Color(0xFF2962FF)
                        : const Color(0xFF1D1D1F),
              ),
            ),
            if (hasEvents && !isToday)
              Container(
                width: 4, height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF2962FF),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
