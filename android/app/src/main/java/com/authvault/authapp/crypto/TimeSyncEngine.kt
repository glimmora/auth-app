package com.authvault.authapp.crypto

import android.util.Log
import java.io.IOException
import java.net.InetAddress
import java.net.SocketException
import java.util.Date
import org.apache.commons.net.ntp.NTPUDPClient
import org.apache.commons.net.ntp.TimeInfo

object TimeSyncEngine {
    private const val TAG = "TimeSyncEngine"
    private const val NTP_SERVER = "pool.ntp.org"
    private const val NTP_TIMEOUT = 5000
    
    private var cachedOffset: Int? = null
    private var lastSyncTime: Long = 0
    
    fun calculateTimeOffset(): Int? {
        return try {
            val client = NTPUDPClient()
            client.defaultTimeout = NTP_TIMEOUT
            
            val address = InetAddress.getByName(NTP_SERVER)
            val timeInfo = client.getTime(address)
            timeInfo.computeDetails()
            
            val offset = timeInfo.offset?.toInt() ?: 0
            val offsetSeconds = offset / 1000
            
            Log.d(TAG, "Calculated time offset: $offsetSeconds seconds")
            
            cachedOffset = offsetSeconds
            lastSyncTime = System.currentTimeMillis()
            
            offsetSeconds
        } catch (e: Exception) {
            Log.e(TAG, "Failed to sync time: ${e.message}")
            null
        }
    }
    
    fun getCachedOffset(): Int? {
        if (System.currentTimeMillis() - lastSyncTime > 3600000) { // Cache for 1 hour
            cachedOffset = null
        }
        return cachedOffset
    }
    
    fun getSuggestedOffsetThreshold(): Int {
        return 30 // Warn if drift more than 30 seconds
    }
    
    fun isDriftSignificant(offset: Int): Boolean {
        return Math.abs(offset) > getSuggestedOffsetThreshold()
    }
}
