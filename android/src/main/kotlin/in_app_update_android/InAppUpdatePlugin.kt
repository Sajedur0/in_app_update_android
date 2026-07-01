package in_app_update_android

import android.app.Activity
import android.app.Application
import android.content.Intent
import com.google.android.play.core.appupdate.AppUpdateInfo
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.ActivityResult
import com.google.android.play.core.install.model.AppUpdateType
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

class InAppUpdatePlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
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

    companion object {
        private const val REQUEST_CODE_START_UPDATE = 1276
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appUpdateManager = AppUpdateManagerFactory.create(binding.applicationContext)
        methodChannel = MethodChannel(binding.binaryMessenger, "in_app_update_android/methods")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, "in_app_update_android/stateEvents")
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        unregisterInstallStateListener()
        pendingResult?.error("ENGINE_DETACHED", "Flutter engine detached before update completed", null)
        pendingResult = null
        appUpdateManager = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityPluginBinding = binding
        binding.addActivityResultListener(this)
        binding.activity.application.registerActivityLifecycleCallbacks(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        unregisterActivityListener()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityPluginBinding = binding
        binding.addActivityResultListener(this)
        binding.activity.application.registerActivityLifecycleCallbacks(this)
    }

    override fun onDetachedFromActivity() {
        pendingResult?.error("ACTIVITY_DETACHED", "Activity was detached before update completed", null)
        pendingResult = null
        unregisterActivityListener()
    }

    private fun unregisterActivityListener() {
        activity?.application?.unregisterActivityLifecycleCallbacks(this)
        activityPluginBinding?.removeActivityResultListener(this)
        activityPluginBinding = null
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "checkForUpdate" -> handleCheckForUpdate(result)
            "performImmediateUpdate" -> handleStartUpdate(call, result, AppUpdateType.IMMEDIATE)
            "startFlexibleUpdate" -> handleStartUpdate(call, result, AppUpdateType.FLEXIBLE)
            "completeFlexibleUpdate" -> handleCompleteUpdate(result)
            else -> result.notImplemented()
        }
    }

    private fun handleCheckForUpdate(result: Result) {
        val manager = appUpdateManager
        if (manager == null) {
            result.error("NO_CONTEXT", "AppUpdateManager is not initialized", null)
            return
        }

        try {
            manager.appUpdateInfo.addOnSuccessListener { info ->
                result.success(serializeAppUpdateInfo(info))
            }.addOnFailureListener { e ->
                result.error("CHECK_UPDATE_FAILED", "Failed to check for updates", e.localizedMessage)
            }
        } catch (e: Exception) {
            result.error("CHECK_UPDATE_FAILED", "Failed to check for updates: ${e.localizedMessage}", null)
        }
    }

    private fun handleStartUpdate(call: MethodCall, result: Result, updateType: Int) {
        val currentActivity = activity
        val manager = appUpdateManager
        val allowAssetPackDeletion =
            call.argument<Boolean>("allowAssetPackDeletion") ?: false

        if (currentActivity == null) {
            result.error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
            return
        }
        if (manager == null) {
            result.error("NO_CONTEXT", "AppUpdateManager is not initialized", null)
            return
        }

        if (pendingResult != null) {
            result.error("ALREADY_RUNNING", "An update flow is already in progress", null)
            return
        }

        pendingResult = result

        try {
            manager.appUpdateInfo.addOnSuccessListener { info ->
                val options = buildUpdateOptions(updateType, allowAssetPackDeletion)

                if (info.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE ||
                    info.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS
                ) {
                    if (!info.isUpdateTypeAllowed(options)) {
                        val preconditions = info.getFailedUpdatePreconditions(options).toList()
                        pendingResult?.error(
                            "UPDATE_NOT_AVAILABLE",
                            "Update type not allowed",
                            preconditions
                        )
                        pendingResult = null
                        return@addOnSuccessListener
                    }

                    try {
                        manager.startUpdateFlowForResult(
                            info, currentActivity, options, REQUEST_CODE_START_UPDATE
                        )
                    } catch (e: Exception) {
                        pendingResult?.error(
                            "UPDATE_FLOW_FAILED",
                            "Failed to start update flow: ${e.localizedMessage}",
                            null
                        )
                        pendingResult = null
                    }
                } else {
                    pendingResult?.error(
                        "UPDATE_NOT_AVAILABLE",
                        "No update available",
                        null
                    )
                    pendingResult = null
                }
            }.addOnFailureListener { e ->
                pendingResult?.error("CHECK_UPDATE_FAILED", "Failed to check for updates: ${e.localizedMessage}", null)
                pendingResult = null
            }
        } catch (e: Exception) {
            pendingResult?.error("CHECK_UPDATE_FAILED", "Failed to check for updates: ${e.localizedMessage}", null)
            pendingResult = null
        }
    }

    private fun handleCompleteUpdate(result: Result) {
        val manager = appUpdateManager
        if (manager == null) {
            result.error("NO_CONTEXT", "AppUpdateManager is not initialized", null)
            return
        }

        try {
            manager.completeUpdate().addOnSuccessListener {
                result.success(null)
            }.addOnFailureListener { e ->
                result.error("COMPLETE_UPDATE_FAILED", "Failed to complete update", e.localizedMessage)
            }
        } catch (e: Exception) {
            result.error("COMPLETE_UPDATE_FAILED", "Failed to complete update: ${e.localizedMessage}", null)
        }
    }

    private fun serializeAppUpdateInfo(info: AppUpdateInfo): Map<String, Any?> {
        val immediateOptions = buildUpdateOptions(AppUpdateType.IMMEDIATE, false)
        val flexibleOptions = buildUpdateOptions(AppUpdateType.FLEXIBLE, false)

        return mapOf(
            "updateAvailability" to info.updateAvailability(),
            "immediateUpdateAllowed" to info.isUpdateTypeAllowed(immediateOptions),
            "immediateAllowedPreconditions" to
                info.getFailedUpdatePreconditions(immediateOptions).toList(),
            "flexibleUpdateAllowed" to info.isUpdateTypeAllowed(flexibleOptions),
            "flexibleAllowedPreconditions" to
                info.getFailedUpdatePreconditions(flexibleOptions).toList(),
            "availableVersionCode" to if (info.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE) {
                info.availableVersionCode()
            } else {
                null
            },
            "installStatus" to info.installStatus(),
            "packageName" to info.packageName(),
            "clientVersionStalenessDays" to info.clientVersionStalenessDays(),
            "updatePriority" to info.updatePriority(),
            "bytesDownloaded" to info.bytesDownloaded(),
            "totalBytesToDownload" to info.totalBytesToDownload(),
        )
    }

    private fun buildUpdateOptions(updateType: Int, allowAssetPackDeletion: Boolean): AppUpdateOptions {
        return AppUpdateOptions.newBuilder(updateType)
            .setAllowAssetPackDeletion(allowAssetPackDeletion)
            .build()
    }

    private fun registerInstallStateListener() {
        val manager = appUpdateManager ?: return
        if (installStateListener == null) {
            installStateListener = InstallStateUpdatedListener { state ->
                val eventData = mapOf(
                    "installStatus" to state.installStatus(),
                    "bytesDownloaded" to state.bytesDownloaded(),
                    "totalBytesToDownload" to state.totalBytesToDownload(),
                    "installErrorCode" to state.installErrorCode()
                )
                eventSink?.success(eventData)
            }
            manager.registerListener(installStateListener!!)
        }
    }

    private fun unregisterInstallStateListener() {
        installStateListener?.let {
            appUpdateManager?.unregisterListener(it)
        }
        installStateListener = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        registerInstallStateListener()
    }

    override fun onCancel(arguments: Any?) {
        unregisterInstallStateListener()
        eventSink = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE_START_UPDATE) return false

        val resultValue = when (resultCode) {
            Activity.RESULT_OK -> 0
            Activity.RESULT_CANCELED -> 1
            ActivityResult.RESULT_IN_APP_UPDATE_FAILED -> 2
            else -> 2
        }

        pendingResult?.success(resultValue)
        pendingResult = null
        return true
    }

    override fun onActivityResumed(activity: Activity) {
        if (activity !== this.activity) return

        try {
            appUpdateManager?.appUpdateInfo?.addOnSuccessListener { info ->
                val currentActivity = this.activity
                if (currentActivity == null) return@addOnSuccessListener
                val options = buildUpdateOptions(AppUpdateType.IMMEDIATE, false)
                if (info.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS &&
                    info.isUpdateTypeAllowed(options)
                ) {
                    try {
                        appUpdateManager?.startUpdateFlowForResult(
                            info,
                            currentActivity,
                            options,
                            REQUEST_CODE_START_UPDATE
                        )
                    } catch (_: Exception) {
                    }
                }
            }
        } catch (_: Exception) {
        }
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: android.os.Bundle?) {}
    override fun onActivityStarted(activity: Activity) {}
    override fun onActivityPaused(activity: Activity) {}
    override fun onActivityStopped(activity: Activity) {}
    override fun onActivitySaveInstanceState(activity: Activity, outState: android.os.Bundle) {}
    override fun onActivityDestroyed(activity: Activity) {}
}
