package com.grany.granny_calendar;

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
