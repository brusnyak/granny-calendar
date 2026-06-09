package com.grany.granny_calendar;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "GrannyCalendar";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Delay icon switching slightly — let Flutter engine settle first.
        // The icon will update right after the app opens, then daily at midnight.
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            try {
                IconSwitcher.ensureCorrectIcon(this);
                DailyIconAlarmReceiver.scheduleNextAlarm(this);
            } catch (Exception e) {
                Log.e(TAG, "Icon setup failed (non-fatal)", e);
            }
        }, 500);
    }
}
