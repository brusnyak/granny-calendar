package com.grany.granny_calendar;

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
