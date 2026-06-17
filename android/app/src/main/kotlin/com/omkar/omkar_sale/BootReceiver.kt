package com.omkar.omkar_sale

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/// On Android 14+ a BroadcastReceiver cannot start a foreground service that
/// needs a slow Flutter engine boot — system throws
/// ForegroundServiceDidNotStartInTimeException.
///
/// Instead we rely on WorkManager persistence: our 3 staggered watchdogs survive
/// reboot (stored in WorkManager DB + RECEIVE_BOOT_COMPLETED permission). After
/// boot, the first watchdog fires within ~5 min, reads shift_config Hive, and
/// starts BackgroundService properly via FlutterBackgroundService API.
///
/// This receiver only logs the boot event for debugging.
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("BootReceiver", "Boot completed: ${intent.action}. WorkManager will restart bg service via watchdog.")
    }
}
