#!/usr/bin/env python3
"""
Generate AndroidManifest.xml with 31 activity aliases
and the Java native code files.
"""

import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ANDROID_DIR = os.path.join(BASE_DIR, "android", "app", "src", "main")
JAVA_DIR = os.path.join(ANDROID_DIR, "java", "com", "grany", "granny_calendar")
RES_DIR = os.path.join(ANDROID_DIR, "res")

# ============================================================
# 1. AndroidManifest.xml
# ============================================================

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

    <!-- Permission for exact alarm scheduling (Android 12+) -->
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"
        android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <application
        android:label="granny_calendar"
        android:name="${{applicationName}}"
        android:icon="@mipmap/ic_day_01"
        android:allowBackup="true"
        android:supportsRtl="true"
        android:theme="@style/AppTheme">

        <!-- MainActivity: NO LAUNCHER intent-filter!
             Launcher access is via activity-alias entries only. -->
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

        <!-- Daily icon change alarm receiver -->
        <receiver
            android:name=".DailyIconAlarmReceiver"
            android:exported="false" />

        <!-- Boot completed receiver to re-schedule daily alarm -->
        <receiver
            android:name=".BootReceiver"
            android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
            </intent-filter>
        </receiver>

        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
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


# ============================================================
# 2. IconSwitcher.java
# ============================================================

def generate_icon_switcher():
    code = '''package com.grany.granny_calendar;

import android.content.ComponentName;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import java.util.Calendar;

/**
 * Utility to switch the launcher icon to show the current day of month.
 * Uses Android's activity-alias mechanism:
 * - 31 aliases defined in AndroidManifest.xml (Day01 .. Day31)
 * - Only today's alias is enabled; all others are disabled
 * - The launcher immediately picks up the change
 */
public class IconSwitcher {
    private static final String PREFS_NAME = "granny_calendar_icon";
    private static final String KEY_LAST_DAY = "last_day";
    private static final String KEY_LAST_MONTH = "last_month";
    private static final String KEY_LAST_YEAR = "last_year";

    /**
     * Check if the icon needs updating, and switch if needed.
     * Call this on app launch and on BOOT_COMPLETED.
     */
    public static void ensureCorrectIcon(Context context) {
        Calendar now = Calendar.getInstance();
        int today = now.get(Calendar.DAY_OF_MONTH);
        int month = now.get(Calendar.MONTH);
        int year = now.get(Calendar.YEAR);

        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        int lastDay = prefs.getInt(KEY_LAST_DAY, -1);
        int lastMonth = prefs.getInt(KEY_LAST_MONTH, -1);
        int lastYear = prefs.getInt(KEY_LAST_YEAR, -1);

        // Only switch if day/month/year changed
        if (lastDay == today && lastMonth == month && lastYear == year) {
            return;
        }

        switchToDay(context, today);
        prefs.edit()
            .putInt(KEY_LAST_DAY, today)
            .putInt(KEY_LAST_MONTH, month)
            .putInt(KEY_LAST_YEAR, year)
            .apply();
    }

    /**
     * Switch the launcher icon to show the given day number.
     */
    public static void switchToDay(Context context, int day) {
        if (day < 1 || day > 31) return;

        PackageManager pm = context.getPackageManager();
        String pkg = context.getPackageName();

        // Build component names for all 31 day aliases
        ComponentName[] allDays = new ComponentName[31];
        for (int i = 0; i < 31; i++) {
            String suffix = String.format(".Day%02d", i + 1);
            allDays[i] = new ComponentName(pkg, pkg + suffix);
        }

        // Disable all aliases
        for (ComponentName cn : allDays) {
            pm.setComponentEnabledSetting(
                cn,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            );
        }

        // Enable today's alias
        String todaySuffix = String.format(".Day%02d", day);
        ComponentName todayAlias = new ComponentName(pkg, pkg + todaySuffix);
        pm.setComponentEnabledSetting(
            todayAlias,
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        );
    }
}
'''
    path = os.path.join(JAVA_DIR, "IconSwitcher.java")
    with open(path, "w") as f:
        f.write(code)
    print(f"✅ IconSwitcher.java generated")


# ============================================================
# 3. DailyIconAlarmReceiver.java
# ============================================================

def generate_alarm_receiver():
    code = '''package com.grany.granny_calendar;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import java.util.Calendar;

/**
 * BroadcastReceiver that fires at ~midnight each day to update the icon.
 * Scheduled by AlarmManager when the app starts or device boots.
 */
public class DailyIconAlarmReceiver extends BroadcastReceiver {
    private static final int ALARM_REQUEST_CODE = 1001;

    @Override
    public void onReceive(Context context, Intent intent) {
        // Update the icon to today's date
        IconSwitcher.ensureCorrectIcon(context);
        // Schedule the next alarm
        scheduleNextAlarm(context);
    }

    /**
     * Schedule the alarm to fire at the next midnight.
     */
    public static void scheduleNextAlarm(Context context) {
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        if (alarmManager == null) return;

        Intent intent = new Intent(context, DailyIconAlarmReceiver.class);
        PendingIntent pendingIntent = PendingIntent.getBroadcast(
            context,
            ALARM_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );

        // Calculate next midnight
        Calendar midnight = Calendar.getInstance();
        midnight.add(Calendar.DAY_OF_MONTH, 1);
        midnight.set(Calendar.HOUR_OF_DAY, 0);
        midnight.set(Calendar.MINUTE, 0);
        midnight.set(Calendar.SECOND, 0);
        midnight.set(Calendar.MILLISECOND, 0);

        // Schedule with exact timing (allow while idle)
        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            midnight.getTimeInMillis(),
            pendingIntent
        );
    }
}
'''
    path = os.path.join(JAVA_DIR, "DailyIconAlarmReceiver.java")
    with open(path, "w") as f:
        f.write(code)
    print(f"✅ DailyIconAlarmReceiver.java generated")


# ============================================================
# 4. BootReceiver.java
# ============================================================

def generate_boot_receiver():
    code = '''package com.grany.granny_calendar;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

/**
 * Re-schedules the daily icon alarm after device reboot.
 */
public class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            // Ensure icon is correct after boot
            IconSwitcher.ensureCorrectIcon(context);
            // Re-schedule the daily alarm
            DailyIconAlarmReceiver.scheduleNextAlarm(context);
        }
    }
}
'''
    path = os.path.join(JAVA_DIR, "BootReceiver.java")
    with open(path, "w") as f:
        f.write(code)
    print(f"✅ BootReceiver.java generated")


# ============================================================
# 5. MainActivity.java
# ============================================================

def generate_main_activity():
    code = '''package com.grany.granny_calendar;

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
'''
    path = os.path.join(JAVA_DIR, "MainActivity.java")
    with open(path, "w") as f:
        f.write(code)
    print(f"✅ MainActivity.java updated with icon switching")


# ============================================================
# 6. Android styles (ensure theme exists for non-launcher activity)
# ============================================================

def generate_styles():
    """Create a base AppTheme for the application tag."""
    values_dir = os.path.join(RES_DIR, "values")
    os.makedirs(values_dir, exist_ok=True)

    styles_path = os.path.join(values_dir, "styles.xml")
    if not os.path.exists(styles_path):
        with open(styles_path, "w") as f:
            f.write('''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Base application theme, referenced by android:theme="@style/AppTheme" -->
    <style name="AppTheme" parent="@android:style/Theme.Material.Light.NoActionBar" />
</resources>
''')
        print(f"✅ styles.xml created")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    os.makedirs(JAVA_DIR, exist_ok=True)
    generate_manifest()
    generate_icon_switcher()
    generate_alarm_receiver()
    generate_boot_receiver()
    generate_main_activity()
    generate_styles()
    print(f"\\n✅ All Android files generated in {ANDROID_DIR}")
