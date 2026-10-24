package ch.synci.app

import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ch.synci.app/browser")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "open" -> result.success(openInBrowser(call.arguments as String))
                    else -> result.notImplemented()
                }
            }
    }

    // A plain VIEW intent would hand calendar.google.com links to the Google Calendar app,
    // which can't subscribe to calendars, so the browser is picked explicitly.
    private fun openInBrowser(url: String): Boolean {
        val browser = browserPackage() ?: return false
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            .addCategory(Intent.CATEGORY_BROWSABLE)
            .setPackage(browser)
        return try {
            startActivity(intent)
            true
        } catch (e: ActivityNotFoundException) {
            false
        }
    }

    // The default browser, else any. Only browsers open a page no app claims; without a
    // default the resolver itself ("android") answers.
    @Suppress("DEPRECATION")
    private fun browserPackage(): String? {
        val probe = Intent(Intent.ACTION_VIEW, Uri.parse("https://example.com"))
            .addCategory(Intent.CATEGORY_BROWSABLE)
        val default = packageManager.resolveActivity(probe, PackageManager.MATCH_DEFAULT_ONLY)
            ?.activityInfo?.packageName
        if (default != null && default != "android") return default
        return packageManager.queryIntentActivities(probe, 0).firstOrNull()?.activityInfo?.packageName
    }
}
