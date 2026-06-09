package com.grany.granny_calendar;

import android.app.AlarmManager;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import androidx.core.app.NotificationCompat;

public class ReminderAlarmReceiver extends BroadcastReceiver {
    private static final String TAG = "ReminderAlarm";
    private static final String CHANNEL_ID = "granny_reminders";
    private static final String EXTRA_TITLE = "event_title";

    @Override
    public void onReceive(Context context, Intent intent) {
        try {
            String title = intent.getStringExtra(EXTRA_TITLE);
            if (title == null) return;

            createNotificationChannel(context);
            showNotification(context, title);
        } catch (Exception e) {
            Log.e(TAG, "onReceive failed", e);
        }
    }

    private void createNotificationChannel(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                CHANNEL_ID,
                "Нагадування",
                NotificationManager.IMPORTANCE_HIGH
            );
            channel.setDescription("Сповіщення про події в календарі");
            NotificationManager nm = context.getSystemService(NotificationManager.class);
            if (nm != null) nm.createNotificationChannel(channel);
        }
    }

    private void showNotification(Context context, String title) {
        Intent i = new Intent(context, MainActivity.class);
        i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent pi = PendingIntent.getActivity(
            context, 0, i,
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );

        NotificationCompat.Builder b = new NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_popup_reminder)
            .setContentTitle("📅 " + title)
            .setContentText("Натисніть, щоб відкрити календар")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pi);

        NotificationManager nm = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        if (nm != null) nm.notify(title.hashCode(), b.build());
    }

    public static void scheduleReminder(Context context, int id, String title, long scheduledAtMs) {
        try {
            AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            if (am == null) return;

            Intent intent = new Intent(context, ReminderAlarmReceiver.class);
            intent.putExtra(EXTRA_TITLE, title);

            PendingIntent pi = PendingIntent.getBroadcast(
                context, id, intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );

            am.set(AlarmManager.RTC_WAKEUP, scheduledAtMs, pi);
        } catch (Exception e) {
            Log.e(TAG, "scheduleReminder failed", e);
        }
    }

    public static void cancelReminder(Context context, int id) {
        try {
            Intent intent = new Intent(context, ReminderAlarmReceiver.class);
            PendingIntent pi = PendingIntent.getBroadcast(
                context, id, intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            pi.cancel();

            AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            if (am != null) am.cancel(pi);
        } catch (Exception e) {
            Log.e(TAG, "cancelReminder failed", e);
        }
    }
}
