package sajedur0.in_app_update_android

import android.app.Activity
import android.app.Application
import android.content.Intent
import android.content.IntentSender
import android.os.Bundle
import com.google.android.play.core.appupdate.AppUpdateInfo
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.ActivityResult
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class InAppUpdateAndroidPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    EventChannel.StreamHandler, PluginRegistry.ActivityResultListener,
    Application.ActivityLifecycleCallbacks {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var activity: Activity? = null
    private var activityPluginBinding: ActivityPluginBinding? = null
    private var appUpdateManager: AppUpdateManager? = null
    private var eventSink: EventChannel.EventSink? = null
    private var installStateListener: InstallStateUpdatedListener? = null
    private var pendingResult: Result? = null
    private var appUpdateType: Int? = null
    private var appUpdateInfo: AppUpdateInfo? = null

    companion object {
        private const val REQUEST_CODE_IMMEDIATE = 1001
        private const val REQUEST_CODE_FLEXIBLE = 1002
    }

    // region FlutterPlugin

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, "in_app_update_android")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, "in_app_update_android/installStateAndroid")
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    // endregion

    // region ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityPluginBinding = binding
        binding.addActivityResultListener(this)
        binding.activity.application.registerActivityLifecycleCallbacks(this)
        appUpdateManager = AppUpdateManagerFactory.create(binding.activity)
        registerInstallStateListener()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        unregisterActivityListener()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityPluginBinding = binding
        binding.addActivityResultListener(this)
        binding.activity.application.registerActivityLifecycleCallbacks(this)
        appUpdateManager = AppUpdateManagerFactory.create(binding.activity)
        registerInstallStateListener()
    }

    override fun onDetachedFromActivity() {
        unregisterActivityListener()
    }

    private fun unregisterActivityListener() {
        installStateListener?.let { appUpdateManager?.unregisterListener(it) }
        installStateListener = null
        eventSink = null
        activity?.application?.unregisterActivityLifecycleCallbacks(this)
        activityPluginBinding?.removeActivityResultListener(this)
        activityPluginBinding = null
        activity = null
        appUpdateManager = null
    }

    // endregion

    // region MethodCallHandler

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "checkForUpdateAndroid" -> handleCheckForUpdate(result)
            "startImmediateUpdateAndroid" -> handleStartUpdate(call, result, AppUpdateType.IMMEDIATE)
            "startFlexibleUpdateAndroid" -> handleStartUpdate(call, result, AppUpdateType.FLEXIBLE)
            "completeUpdateAndroid" -> handleCompleteUpdate(result)
            else -> result.notImplemented()
        }
    }

    private fun handleCheckForUpdate(result: Result) {
        val manager = appUpdateManager
        if (manager == null) {
            result.error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
            return
        }

        manager.appUpdateInfo.addOnSuccessListener { info ->
            result.success(serializeAppUpdateInfo(info))
        }.addOnFailureListener { e ->
            result.error("CHECK_UPDATE_FAILED", "Failed to check for updates", e.localizedMessage)
        }
    }

    private fun handleStartUpdate(call: MethodCall, result: Result, updateType: Int) {
        val currentActivity = activity
        val manager = appUpdateManager

        if (currentActivity == null || manager == null) {
            result.error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
            return
        }

        if (pendingResult != null) {
            result.error("ALREADY_RUNNING", "An update flow is already in progress", null)
            return
        }

        pendingResult = result
        appUpdateType = updateType

        val allowAssetPackDeletion = call.argument<Boolean>("allowAssetPackDeletion") ?: false

        manager.appUpdateInfo.addOnSuccessListener { info ->
            this.appUpdateInfo = info

            if (info.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE ||
                info.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS
            ) {
                if (!info.isUpdateTypeAllowed(updateType)) {
                    pendingResult?.error(
                        "UPDATE_NOT_AVAILABLE",
                        "Update type not allowed",
                        null
                    )
                    pendingResult = null
                    return@addOnSuccessListener
                }

                val options = AppUpdateOptions.newBuilder(updateType)
                    .setAllowAssetPackDeletion(allowAssetPackDeletion)
                    .build()

                val requestCode = if (updateType == AppUpdateType.IMMEDIATE) {
                    REQUEST_CODE_IMMEDIATE
                } else {
                    REQUEST_CODE_FLEXIBLE
                }

                try {
                    manager.startUpdateFlowForResult(info, currentActivity, options, requestCode)
                } catch (e: IntentSender.SendIntentException) {
                    pendingResult?.error(
                        "UPDATE_FLOW_FAILED",
                        "Failed to start update flow: ${e.localizedMessage}",
                        null
                    )
                    pendingResult = null
                    this.appUpdateType = null
                }
            } else {
                pendingResult?.error(
                    "UPDATE_NOT_AVAILABLE",
                    "No update available or update type not allowed",
                    null
                )
                pendingResult = null
            }
        }.addOnFailureListener { e ->
            pendingResult?.error("CHECK_UPDATE_FAILED", "Failed to check for updates", e.localizedMessage)
            pendingResult = null
        }
    }

    private fun handleCompleteUpdate(result: Result) {
        val manager = appUpdateManager
        if (manager == null) {
            result.error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
            return
        }

        manager.completeUpdate().addOnSuccessListener {
            result.success(null)
        }.addOnFailureListener { e ->
            result.error("COMPLETE_UPDATE_FAILED", "Failed to complete update", e.localizedMessage)
        }
    }

    private fun serializeAppUpdateInfo(info: AppUpdateInfo): Map<String, Any?> {
        return mapOf(
            "updateAvailability" to info.updateAvailability(),
            "availableVersionCode" to if (info.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE) {
                info.availableVersionCode()
            } else {
                null
            },
            "updatePriority" to info.updatePriority(),
            "clientVersionStalenessDays" to info.clientVersionStalenessDays(),
            "isImmediateUpdateAllowed" to info.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE),
            "isFlexibleUpdateAllowed" to info.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE),
            "installStatus" to info.installStatus(),
        )
    }

    // endregion

    // region InstallStateListener & EventChannel.StreamHandler

    private fun registerInstallStateListener() {
        if (installStateListener != null) return
        installStateListener = InstallStateUpdatedListener { state ->
            eventSink?.success(
                mapOf(
                    "status" to state.installStatus(),
                    "bytesDownloaded" to state.bytesDownloaded(),
                    "totalBytesToDownload" to state.totalBytesToDownload(),
                )
            )
        }
        appUpdateManager?.registerListener(installStateListener!!)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    // endregion

    // region ActivityResultListener

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE_IMMEDIATE && requestCode != REQUEST_CODE_FLEXIBLE) {
            return false
        }

        val resultValue = when (resultCode) {
            Activity.RESULT_OK -> 0 // success
            Activity.RESULT_CANCELED -> 1 // userCanceled
            ActivityResult.RESULT_IN_APP_UPDATE_FAILED -> 2 // inAppUpdateFailed
            else -> 2 // inAppUpdateFailed
        }

        pendingResult?.success(resultValue)
        pendingResult = null
        appUpdateType = null
        return true
    }

    // endregion

    // region Application.ActivityLifecycleCallbacks

    override fun onActivityResumed(activity: Activity) {
        if (activity !== this.activity) return

        appUpdateManager?.appUpdateInfo?.addOnSuccessListener { info ->
            if (info.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS &&
                info.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE)
            ) {
                try {
                    appUpdateManager?.startUpdateFlowForResult(
                        info,
                        activity,
                        AppUpdateOptions.newBuilder(AppUpdateType.IMMEDIATE).build(),
                        REQUEST_CODE_IMMEDIATE
                    )
                } catch (e: IntentSender.SendIntentException) {
                    // Could not restart the update flow
                }
            }
        }
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
    override fun onActivityStarted(activity: Activity) {}
    override fun onActivityPaused(activity: Activity) {}
    override fun onActivityStopped(activity: Activity) {}
    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
    override fun onActivityDestroyed(activity: Activity) {}

    // endregion
}
