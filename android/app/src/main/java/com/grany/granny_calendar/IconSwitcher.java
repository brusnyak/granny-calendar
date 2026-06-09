package com.grany.granny_calendar;

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
