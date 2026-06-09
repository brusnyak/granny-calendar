package com.grany.granny_calendar;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "GrannyCalendar";
    private static final String CHANNEL = "com.grany.granny_calendar/reminders";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                switch (call.method) {
                    case "requestNotificationPermission":
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
                                    != PackageManager.PERMISSION_GRANTED) {
                                ActivityCompat.requestPermissions(
                                    this, new String[]{Manifest.permission.POST_NOTIFICATIONS}, 100
                                );
                            }
                        }
                        result.success(true);
                        break;
                    case "scheduleReminder":
                        int id = call.argument("id");
                        String title = call.argument("title");
                        double scheduledAtMs = call.argument("scheduledAtMs");
                        ReminderAlarmReceiver.scheduleReminder(
                            this, id, title, (long) scheduledAtMs
                        );
                        result.success(true);
                        break;
                    case "cancelReminder":
                        int cancelId = call.argument("id");
                        ReminderAlarmReceiver.cancelReminder(this, cancelId);
                        result.success(true);
                        break;
                    default:
                        result.notImplemented();
                }
            });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

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
