package com.authvault.authapp.data

import android.content.Context
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object AuditLogger {
    private const val PREFS_NAME = "audit_log"
    
    enum class EventType {
        UNLOCK_SUCCESS,
        UNLOCK_FAILURE,
        CODE_COPIED,
        ACCOUNT_ADDED,
        ACCOUNT_DELETED,
        ACCOUNT_UPDATED,
        EXPORT_BACKUP,
        IMPORT_BACKUP,
        SETTINGS_CHANGED
    }
    
    data class AuditEntry(
        val timestamp: Long,
        val eventType: EventType,
        val details: String,
        val previousHash: String = ""
    ) {
        fun computeHash(): String {
            val data = "$timestamp:${eventType.name}:$details:$previousHash"
            return data.hashCode().toString(16)
        }
        
        fun verifyHash(): Boolean {
            return computeHash() == details
        }
    }
    
    fun logEvent(context: Context, eventType: EventType, details: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val lastHash = prefs.getString("last_hash", "0") ?: "0"
        
        val entry = AuditEntry(
            timestamp = System.currentTimeMillis(),
            eventType = eventType,
            details = details,
            previousHash = lastHash
        )
        
        val hash = entry.computeHash()
        
        val logEntries = prefs.getString("log_entries", "[]") ?: "[]"
        val newEntry = """{"timestamp":${entry.timestamp},"type":"${eventType.name}","details":"${entry.details}","hash":"$hash"}"""
        
        val updatedLog = logEntries.dropLast(1).drop(1).let {
            if (it.isEmpty()) "[$newEntry]" else "[$it,$newEntry]"
        }
        
        prefs.edit()
            .putString("log_entries", updatedLog)
            .putString("last_hash", hash)
            .apply()
    }
    
    fun getLogEntries(context: Context): List<AuditEntry> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val logJson = prefs.getString("log_entries", "[]") ?: "[]"
        return emptyList()
    }
    
    fun verifyIntegrity(context: Context): Boolean {
        val entries = getLogEntries(context)
        var previousHash = "0"
        
        for (entry in entries) {
            if (entry.previousHash != previousHash) {
                return false
            }
            previousHash = entry.computeHash()
        }
        
        return true
    }
}
