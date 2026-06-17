package com.omkar.sale

import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.omkar.sale/oem"

    // Oppo / ColorOS / Oplus Auto-launch & Startup Manager component fallbacks.
    // Ordered newest-first: Oplus (ColorOS 13+), ColorOS, OPPO legacy.
    // CPH2603 (Oppo F25 Pro, ColorOS 14) needs the oplus.* entries.
    private val oppoAutoStartIntents = listOf(
        // ColorOS 13/14 — Oplus rebrand
        ComponentName(
            "com.oplus.safecenter",
            "com.oplus.safecenter.permission.startup.StartupAppListActivity",
        ),
        ComponentName(
            "com.oplus.safecenter",
            "com.oplus.safecenter.startupapp.StartupAppListActivity",
        ),
        ComponentName(
            "com.oplus.safecenter",
            "com.oplus.privacypermissionsentry.PermissionTopActivity",
        ),
        ComponentName(
            "com.oplus.battery",
            "com.oplus.powermanager.fuelgaue.PowerConsumptionActivity",
        ),
        // ColorOS 11/12 — coloros.*
        ComponentName(
            "com.coloros.safecenter",
            "com.coloros.safecenter.permission.startup.StartupAppListActivity",
        ),
        ComponentName(
            "com.coloros.safecenter",
            "com.coloros.safecenter.startupapp.StartupAppListActivity",
        ),
        ComponentName(
            "com.coloros.safecenter",
            "com.coloros.privacypermissionsentry.PermissionTopActivity",
        ),
        ComponentName(
            "com.coloros.oppoguardelf",
            "com.coloros.powermanager.fuelgaue.PowerUsageModelActivity",
        ),
        // Legacy OPPO
        ComponentName(
            "com.oppo.safe",
            "com.oppo.safe.permission.startup.StartupAppListActivity",
        ),
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openOppoAutoStart" -> result.success(tryOppoIntents())
                    "openAppDetailsSettings" -> result.success(openAppDetails())
                    else -> result.notImplemented()
                }
            }
    }

    private fun tryOppoIntents(): Boolean {
        for (component in oppoAutoStartIntents) {
            try {
                val intent = Intent().apply {
                    this.component = component
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                return true
            } catch (_: ActivityNotFoundException) {
                continue
            } catch (_: SecurityException) {
                continue
            } catch (_: Exception) {
                continue
            }
        }
        // Final fallback: app-details page. User can manually tap
        // "Battery → Allow background activity" and "Auto-launch".
        return openAppDetails()
    }

    private fun openAppDetails(): Boolean {
        return try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", packageName, null)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }
}
