import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'calendar_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _requestNotificationPermission();
  runApp(const GrannyCalendarApp());
}

/// Request POST_NOTIFICATIONS permission on Android 13+.
Future<void> _requestNotificationPermission() async {
  try {
    await const MethodChannel('com.grany.granny_calendar/reminders')
        .invokeMethod('requestNotificationPermission');
  } catch (_) {
    // Permission request is best-effort
  }
}

class GrannyCalendarApp extends StatelessWidget {
  const GrannyCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Granny Calendar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2962FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const CalendarPage(),
    );
  }
}
