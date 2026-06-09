package com.grany.granny_calendar;

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
