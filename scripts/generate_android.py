#!/usr/bin/env python3
"""
Generate AndroidManifest.xml with 31 activity aliases
and the Java native code files.
"""

import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ANDROID_DIR = os.path.join(BASE_DIR, "android", "app", "src", "main")
JAVA_DIR = os.path.join(ANDROID_DIR, "java", "com", "grany", "granny_calendar")


def generate_manifest():
    alias_entries = []
    for day in range(1, 32):
        enabled = "true" if day == 1 else "false"
        name = f"Day{day:02d}"
        alias_entries.append(f'''        <activity-alias
            android:name=".{name}"
            android:enabled="{enabled}"
            android:exported="true"
            android:icon="@mipmap/ic_day_{day:02d}"
            android:targetActivity=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity-alias>''')

    aliases_xml = "\n".join(alias_entries)

    manifest = f'''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <application
        android:label="granny_calendar"
        android:name="${{applicationName}}"
        android:icon="@mipmap/ic_day_01">

        <!--
            MainActivity: NO LAUNCHER intent-filter!
            Launcher access is entirely through the activity-alias entries below.
            This prevents "Activity class does not exist" when switching icons.
        -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTask"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
        </activity>

{aliases_xml}

        <!-- Daily icon change: fires at midnight to update the launcher icon -->
        <receiver
            android:name=".DailyIconAlarmReceiver"
            android:exported="false" />

        <!-- Re-schedule daily alarm after device reboot -->
        <receiver
            android:name=".BootReceiver"
            android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
            </intent-filter>
        </receiver>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>

    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
'''
    path = os.path.join(ANDROID_DIR, "AndroidManifest.xml")
    with open(path, "w") as f:
        f.write(manifest)
    print(f"✅ AndroidManifest.xml generated ({31} activity aliases)")


def generate_icon_switcher():
    code = '''package com.grany.granny_calendar;

import android.content.ComponentName;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.util.Log;
import java.util.Calendar;

public class IconSwitcher {
    private static final String TAG = "IconSwitcher";
    private static final String PREFS_NAME = "granny_calendar_icon";
    private static final String KEY_LAST_DAY = "last_day";
    private static final String KEY_LAST_MONTH = "last_month";
    private static final String KEY_LAST_YEAR = "last_year";

    public static void ensureCorrectIcon(Context context) {
        try {
            Calendar now = Calendar.getInstance();
            int today = now.get(Calendar.DAY_OF_MONTH);
            int month = now.get(Calendar.MONTH);
            int year = now.get(Calendar.YEAR);

            SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
            int lastDay = prefs.getInt(KEY_LAST_DAY, -1);
            int lastMonth = prefs.getInt(KEY_LAST_MONTH, -1);
            int lastYear = prefs.getInt(KEY_LAST_YEAR, -1);

            if (lastDay == today && lastMonth == month && lastYear == year) {
                return; // Already correct
            }

            switchToDay(context, today);
            prefs.edit()
                .putInt(KEY_LAST_DAY, today)
                .putInt(KEY_LAST_MONTH, month)
                .putInt(KEY_LAST_YEAR, year)
                .apply();
        } catch (Exception e) {
            Log.e(TAG, "Failed to update icon", e);
        }
    }

    public static void switchToDay(Context context, int day) {
        if (day < 1 || day > 31) return;
        try {
            PackageManager pm = context.getPackageManager();
            String pkg = context.getPackageName();

            ComponentName[] allDays = new ComponentName[31];
            for (int i = 0; i < 31; i++) {
                String suffix = String.format(".Day%02d", i + 1);
                allDays[i] = new ComponentName(pkg, pkg + suffix);
            }

            for (ComponentName cn : allDays) {
                pm.setComponentEnabledSetting(
                    cn,
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                );
            }

            String todaySuffix = String.format(".Day%02d", day);
            ComponentName todayAlias = new ComponentName(pkg, pkg + todaySuffix);
            pm.setComponentEnabledSetting(
                todayAlias,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            );
        } catch (Exception e) {
            Log.e(TAG, "switchToDay failed", e);
        }
    }
}
'''
    path = os.path.join(JAVA_DIR, "IconSwitcher.java")
    with open(path, "w") as f:
        f.write(code)
    print(f"✅ IconSwitcher.java generated")


def generate_alarm_receiver():
    code = '''package com.grany.granny_calendar;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import java.util.Calendar;

public class DailyIconAlarmReceiver extends BroadcastReceiver {
    private static final String TAG = "DailyIconAlarm";
    private static final int ALARM_REQUEST_CODE = 1001;

    @Override
    public void onReceive(Context context, Intent intent) {
        try {
            IconSwitcher.ensureCorrectIcon(context);
            scheduleNextAlarm(context);
        } catch (Exception e) {
            Log.e(TAG, "onReceive failed", e);
        }
    }

    public static void scheduleNextAlarm(Context context) {
        try {
            AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            if (alarmManager == null) return;

            Intent intent = new Intent(context, DailyIconAlarmReceiver.class);
            PendingIntent pendingIntent = PendingIntent.getBroadcast(
                context,
                ALARM_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );

            Calendar midnight = Calendar.getInstance();
            midnight.add(Calendar.DAY_OF_MONTH, 1);
            midnight.set(Calendar.HOUR_OF_DAY, 0);
            midnight.set(Calendar.MINUTE, 0);
            midnight.set(Calendar.SECOND, 0);
            midnight.set(Calendar.MILLISECOND, 0);

            // Inexact is fine — the icon just needs to update sometime
            // around midnight. This avoids SCHEDULE_EXACT_ALARM permission
            // which is restricted on Android 14+.
            alarmManager.set(AlarmManager.RTC_WAKEUP, midnight.getTimeInMillis(), pendingIntent);
        } catch (Exception e) {
            Log.e(TAG, "scheduleNextAlarm failed", e);
        }
    }
}
'''
    path = os.path.join(JAVA_DIR, "DailyIconAlarmReceiver.java")
    with open(path, "w") as f:
        f.write(code)
    print(f"✅ DailyIconAlarmReceiver.java generated")


def generate_boot_receiver():
    code = '''package com.grany.granny_calendar;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class BootReceiver extends BroadcastReceiver {
    private static final String TAG = "BootReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        try {
            if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
                IconSwitcher.ensureCorrectIcon(context);
                DailyIconAlarmReceiver.scheduleNextAlarm(context);
            }
        } catch (Exception e) {
            Log.e(TAG, "onReceive failed", e);
        }
    }
}
'''
    path = os.path.join(JAVA_DIR, "BootReceiver.java")
    with open(path, "w") as f:
        f.write(code)
    print(f"✅ BootReceiver.java generated")


def generate_main_activity():
    code = '''package com.grany.granny_calendar;

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
'''
    path = os.path.join(JAVA_DIR, "MainActivity.java")
    with open(path, "w") as f:
        f.write(code)
    print(f"✅ MainActivity.java generated (delayed icon switching)")


if __name__ == "__main__":
    os.makedirs(JAVA_DIR, exist_ok=True)
    generate_manifest()
    generate_icon_switcher()
    generate_alarm_receiver()
    generate_boot_receiver()
    generate_main_activity()
    print(f"\n✅ All Android files generated in {ANDROID_DIR}")
