package com.grany.granny_calendar;

import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Ensure the launcher icon shows today's date
        IconSwitcher.ensureCorrectIcon(this);
        // Schedule the alarm for tomorrow's icon update
        DailyIconAlarmReceiver.scheduleNextAlarm(this);
    }
}
