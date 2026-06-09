import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'l10n/strings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GrannyCalendarApp());
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
          seedColor: const Color(0xFF2962FF), // Calendar blue
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const CalendarPage(),
    );
  }
}
