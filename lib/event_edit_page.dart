import 'package:flutter/material.dart';
import 'storage.dart';
import 'l10n/strings.dart';

/// Page to add or edit a single event.
class EventEditPage extends StatefulWidget {
  final CalendarEvent? event;
  final DateTime selectedDate;
  final AppStrings s;

  const EventEditPage({
    super.key,
    this.event,
    required this.selectedDate,
    required this.s,
  });

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  late TextEditingController _controller;
  late bool _reminder;
  TimeOfDay? _time;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.event?.title ?? '');
    _reminder = widget.event?.reminder ?? false;
    _time = widget.event?.time;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay(hour: 12, minute: 0),
    );
    if (t != null) setState(() => _time = t);
  }

  void _save() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    final event = CalendarEvent(
      id: widget.event?.id,
      title: title,
      date: widget.selectedDate,
      time: _time,
      reminder: _reminder,
    );

    Navigator.of(context).pop(event);
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hour.toString().padLeft(2, '0');
    final min = t.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? widget.s.editEvent : widget.s.addEvent),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              _s.save,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date display
            Text(
              _formatDate(widget.selectedDate),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Title text field
            TextField(
              controller: _controller,
              autofocus: !_isEditing,
              decoration: InputDecoration(
                hintText: _s.eventHint,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
            ),

            const SizedBox(height: 24),

            // Time picker row
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey[600], size: 22),
                    const SizedBox(width: 12),
                    Text(
                      _time != null
                          ? '${_s.timeLabel}: ${_formatTime(_time!)}'
                          : _s.noTime,
                      style: TextStyle(
                        fontSize: 16,
                        color: _time != null ? Colors.black87 : Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    if (_time != null)
                      GestureDetector(
                        onTap: () => setState(() => _time = null),
                        child: Icon(Icons.close, color: Colors.grey[400], size: 20),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Reminder toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _s.reminderLabel,
                style: const TextStyle(fontSize: 16),
              ),
              subtitle: _reminder
                  ? Text(
                      _s.reminderOn,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    )
                  : null,
              value: _reminder,
              onChanged: (v) => setState(() => _reminder = v),
              activeTrackColor: const Color(0xFF2962FF).withValues(alpha: 0.4),
              activeThumbColor: const Color(0xFF2962FF),
            ),

            if (_reminder && _time == null)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  _s.reminderNoTime,
                  style: TextStyle(fontSize: 13, color: Colors.orange[700]),
                ),
              ),

            const Spacer(),

            // Delete button (edit mode only)
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop('delete'),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text(
                    _s.deleteEvent,
                    style: const TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final day = d.day;
    final month = _s.months[d.month - 1];
    final year = d.year;
    return '$day $month $year';
  }

  AppStrings get _s => widget.s;
}
