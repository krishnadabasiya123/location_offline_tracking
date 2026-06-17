package com.omkar.omkar_sale

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        suppressGeolocatorNotificationChannel()
    }

    // Geolocator creates "geolocator_channel_01" with IMPORTANCE_NONE.
    // Recreate it at IMPORTANCE_MIN so only the shift notification is visible.
    private fun suppressGeolocatorNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.deleteNotificationChannel("geolocator_channel_01")
        val channel = NotificationChannel(
            "geolocator_channel_01",
            "Location Tracking (System)",
            NotificationManager.IMPORTANCE_MIN,
        ).apply {
            description = "Internal geolocator foreground service channel"
            setShowBadge(false)
            lockscreenVisibility = Notification.VISIBILITY_SECRET
        }
        manager.createNotificationChannel(channel)
    }
}
