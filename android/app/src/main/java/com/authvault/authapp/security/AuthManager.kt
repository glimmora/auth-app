package com.authvault.authapp.security

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.PBEKeySpec
import javax.crypto.spec.SecretKeySpec
import java.security.SecureRandom

object AuthManager {
    private const val AUTH_KEYSTORE = "AndroidKeyStore"
    private const val AUTH_KEY_ALIAS = "AuthVault_AuthKey"
    private const val PIN_KEY_ALIAS = "AuthVault_PINKey"
    private const val MAX_FAILED_ATTEMPTS = 5
    private const val COOLDOWN_MS = 30000L
    
    private var failedAttempts = 0
    private var lastFailedTime = 0L
    private var isLocked = false
    
    data class AuthConfig(
        val pinEnabled: Boolean = false,
        val biometricEnabled: Boolean = false,
        val autoLockSeconds: Int = 60
    )
    
    fun initializeAuth(): Boolean {
        return try {
            val keyStore = KeyStore.getInstance(AUTH_KEYSTORE)
            keyStore.load(null)
            
            if (!keyStore.containsAlias(AUTH_KEY_ALIAS)) {
                val keyGenerator = KeyGenerator.getInstance(
                    KeyProperties.KEY_ALGORITHM_AES,
                    AUTH_KEYSTORE
                )
                
                keyGenerator.init(
                    KeyGenParameterSpec.Builder(
                        AUTH_KEY_ALIAS,
                        KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
                    )
                    .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                    .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                    .setKeySize(256)
                    .setUserAuthenticationRequired(false)
                    .build()
                )
                
                keyGenerator.generateKey()
            }
            true
        } catch (e: Exception) {
            false
        }
    }
    
    fun setPin(pin: String): Boolean {
        return try {
            val salt = generateRandomBytes(16)
            val key = deriveKeyFromPin(pin, salt)
            
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            cipher.init(Cipher.ENCRYPT_MODE, getAuthKey())
            
            val iv = cipher.iv
            val encrypted = cipher.doFinal(key.encoded)
            
            val encoded = Base64.encodeToString(iv + salt + encrypted, Base64.NO_WRAP)
            
            val prefs = android.preference.PreferenceManager.getDefaultSharedPreferences(
                com.authvault.authapp.AppContext.get()
            )
            prefs.edit().putString("pin_hash", encoded).apply()
            
            prefs.edit().putBoolean("pin_enabled", true).apply()
            failedAttempts = 0
            true
        } catch (e: Exception) {
            false
        }
    }
    
    fun verifyPin(pin: String): Boolean {
        if (isLocked) {
            val elapsed = System.currentTimeMillis() - lastFailedTime
            if (elapsed < COOLDOWN_MS) {
                return false
            } else {
                isLocked = false
                failedAttempts = 0
            }
        }
        
        return try {
            val prefs = android.preference.PreferenceManager.getDefaultSharedPreferences(
                com.authvault.authapp.AppContext.get()
            )
            val stored = prefs.getString("pin_hash", null) ?: return false
            
            val decoded = Base64.decode(stored, Base64.NO_WRAP)
            val iv = decoded.copyOfRange(0, 12)
            val salt = decoded.copyOfRange(12, 28)
            val encrypted = decoded.copyOfRange(28, decoded.size)
            
            val key = deriveKeyFromPin(pin, salt)
            
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            val spec = GCMParameterSpec(128, iv)
            cipher.init(Cipher.DECRYPT_MODE, getAuthKey(), spec)
            
            val decrypted = cipher.doFinal(encrypted)
            
            val success = key.encoded.contentEquals(decrypted)
            
            if (success) {
                failedAttempts = 0
            } else {
                failedAttempts++
                lastFailedTime = System.currentTimeMillis()
                
                if (failedAttempts >= MAX_FAILED_ATTEMPTS) {
                    isLocked = true
                }
            }
            
            success
        } catch (e: Exception) {
            failedAttempts++
            lastFailedTime = System.currentTimeMillis()
            false
        }
    }
    
    fun isLocked(): Boolean {
        return isLocked
    }
    
    fun getRemainingCooldown(): Long {
        if (!isLocked) return 0
        val elapsed = System.currentTimeMillis() - lastFailedTime
        return maxOf(0, COOLDOWN_MS - elapsed)
    }
    
    fun resetLockout() {
        failedAttempts = 0
        isLocked = false
    }
    
    private fun getAuthKey(): SecretKey {
        val keyStore = KeyStore.getInstance(AUTH_KEYSTORE)
        keyStore.load(null)
        return keyStore.getKey(AUTH_KEY_ALIAS, null) as SecretKey
    }
    
    private fun deriveKeyFromPin(pin: String, salt: ByteArray): SecretKey {
        val spec = PBEKeySpec(pin.toCharArray(), salt, 100000, 256)
        val factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
        val keyBytes = factory.generateSecret(spec).encoded
        return SecretKeySpec(keyBytes, "AES")
    }
    
    private fun generateRandomBytes(length: Int): ByteArray {
        val random = SecureRandom()
        val bytes = ByteArray(length)
        random.nextBytes(bytes)
        return bytes
    }
}
