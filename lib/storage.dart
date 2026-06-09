import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A simple text note tied to a date.
class CalendarEvent {
  final String id;
  String title;
  final DateTime date;
  TimeOfDay? time;
  bool reminder;

  CalendarEvent({
    String? id,
    required this.title,
    required this.date,
    this.time,
    this.reminder = false,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': '${date.year}-${_pad(date.month)}-${_pad(date.day)}',
        'time': time != null
            ? '${_pad(time!.hour)}:${_pad(time!.minute)}'
            : null,
        'reminder': reminder,
      };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    final dateParts = (json['date'] as String).split('-').map(int.parse).toList();
    TimeOfDay? time;
    if (json['time'] != null) {
      final t = (json['time'] as String).split(':').map(int.parse).toList();
      time = TimeOfDay(hour: t[0], minute: t[1]);
    }
    return CalendarEvent(
      id: json['id'] as String?,
      title: json['title'] as String,
      date: DateTime(dateParts[0], dateParts[1], dateParts[2]),
      time: time,
      reminder: json['reminder'] as bool? ?? false,
    );
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}

/// Key helper for SharedPreferences.
String _eventsKey(DateTime date) =>
    'events_${date.year}-${CalendarEvent._pad(date.month)}-${CalendarEvent._pad(date.day)}';

/// Load events for a specific date.
Future<List<CalendarEvent>> loadEvents(DateTime date) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_eventsKey(date));
  if (raw == null || raw.isEmpty) return [];
  final list = jsonDecode(raw) as List;
  return list.map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>)).toList();
}

/// Save events for a specific date (replaces all).
Future<void> saveEvents(DateTime date, List<CalendarEvent> events) async {
  final prefs = await SharedPreferences.getInstance();
  if (events.isEmpty) {
    await prefs.remove(_eventsKey(date));
  } else {
    await prefs.setString(
      _eventsKey(date),
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
  }
}

/// Add or update an event. If [oldId] is provided, replaces that event.
Future<void> upsertEvent(DateTime date, CalendarEvent event, {String? oldId}) async {
  final events = await loadEvents(date);
  if (oldId != null) {
    final idx = events.indexWhere((e) => e.id == oldId);
    if (idx >= 0) {
      events[idx] = event;
    } else {
      events.add(event);
    }
  } else {
    events.add(event);
  }
  await saveEvents(date, events);
}

/// Delete an event by id.
Future<void> deleteEvent(DateTime date, String eventId) async {
  final events = await loadEvents(date);
  events.removeWhere((e) => e.id == eventId);
  await saveEvents(date, events);
}
