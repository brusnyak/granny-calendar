package com.grany.granny_calendar;

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
