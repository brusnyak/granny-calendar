import 'package:flutter/services.dart';
import 'storage.dart';

const _channel = MethodChannel('com.grany.granny_calendar/reminders');

/// Schedule a one-shot notification for an event with a reminder time.
Future<void> scheduleReminder(CalendarEvent event) async {
  if (!event.reminder || event.time == null) return;

  final now = DateTime.now();
  final scheduled = DateTime(
    event.date.year,
    event.date.month,
    event.date.day,
    event.time!.hour,
    event.time!.minute,
  );

  // Don't schedule in the past
  if (scheduled.isBefore(now)) return;

  try {
    await _channel.invokeMethod('scheduleReminder', {
      'id': event.id.hashCode,
      'title': event.title,
      'scheduledAtMs': scheduled.millisecondsSinceEpoch.toDouble(),
    });
  } catch (e) {
    // Silently fail — reminders are non-critical
  }
}

/// Cancel a previously scheduled reminder.
Future<void> cancelReminder(String eventId) async {
  try {
    await _channel.invokeMethod('cancelReminder', {
      'id': eventId.hashCode,
    });
  } catch (e) {
    // Silently fail
  }
}
