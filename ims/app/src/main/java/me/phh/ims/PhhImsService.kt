//SPDX-License-Identifier: GPL-2.0
package me.phh.ims

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Binder
import android.os.SystemClock
import android.telephony.Rlog
import android.telephony.ims.ImsService
import android.telephony.ims.feature.MmTelFeature
import android.telephony.ims.feature.RcsFeature
import android.telephony.ims.stub.ImsConfigImplBase
import android.telephony.ims.stub.ImsRegistrationImplBase
import android.telephony.imsmedia.ImsMediaManager

class PhhImsService : ImsService() {
    companion object {
        private const val TAG = "PHH ImsService"
        var instance: PhhImsService? = null
    }

    val receiver: PhhImsBroadcastReceiver = PhhImsBroadcastReceiver()

    override fun onCreate() {
        Rlog.d(TAG, "onCreate")

        val intentFilter = IntentFilter()
        intentFilter.addAction(receiver.ALARM_PERIODIC_REGISTER)
        intentFilter.addAction("android.intent.action.SIM_STATE_CHANGED")
        this.registerReceiver(receiver, intentFilter, Context.RECEIVER_NOT_EXPORTED)

        this.armPeriodicRegisterAlarm()
    }
    fun armPeriodicRegisterAlarm() {
        val alarmManager = this.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        // Must be explicit: implicit broadcasts don't reach a RECEIVER_NOT_EXPORTED receiver
        // (only worked before because the app ran as android.uid.system), and without the
        // periodic REGISTER the registration lapses after the network's 1 h expiry.
        val intent = Intent(receiver.ALARM_PERIODIC_REGISTER).setPackage(packageName)
        val pendingIntent =
            PendingIntent.getBroadcast(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)
        // Re-register every 30 min (networks commonly grant 3600 s). Recurring alarms don't
        // wake up from doze, so the alarm re-arms itself.
        alarmManager.setAndAllowWhileIdle(
            AlarmManager.ELAPSED_REALTIME_WAKEUP,
            SystemClock.elapsedRealtime() + 1_800_000,
            pendingIntent
        )
        Rlog.d(TAG, "Alarm set")
    }

    // Each SIM slot has independent MMTEL and registration state.
    val mmTelFeatures = mutableMapOf<Int, PhhMmTelFeature>()
    override fun createMmTelFeature(slotId: Int): MmTelFeature {
        Rlog.d(TAG, "createMmTelFeature for slot $slotId")
        return synchronized(mmTelFeatures) {
            mmTelFeatures.getOrPut(slotId) { PhhMmTelFeature(slotId) }
        }
    }

    fun registerAllMmTelFeatures() {
        val features = synchronized(mmTelFeatures) { mmTelFeatures.values.toList() }
        features.forEach { it.registerIfReady() }
    }
    override fun createRcsFeature(slotId: Int): RcsFeature? {
        Rlog.d(TAG, "createRcsFeature")
        return null
    }

    val config = PhhImsConfig()

    override fun getConfig(slotId: Int): ImsConfigImplBase {
        Rlog.d(TAG, "getConfig")
        return config
    }

    class LocalBinder : Binder() {
        fun getService(): PhhImsService {
            Rlog.d(TAG, "LocalBinder getService")
            return PhhImsService()
        }
    }

    private val imsRegistrations = mutableMapOf<Int, ImsRegistrationImplBase>()
    override fun getRegistration(slotId: Int): ImsRegistrationImplBase {
        Rlog.d(TAG, "getRegistration $slotId")
        return synchronized(imsRegistrations) {
            imsRegistrations.getOrPut(slotId) { ImsRegistrationImplBase() }
        }
    }

    override fun onDestroy() {
        Rlog.d(TAG, "onDestroy")
        instance = null
    }

    override fun readyForFeatureCreation() {
        Rlog.d(TAG, "readyForFeatureCreation")
        if (instance != null && instance !== this) {
            throw RuntimeException()
        }
        instance = this
    }
}
