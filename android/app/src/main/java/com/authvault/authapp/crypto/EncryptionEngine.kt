package com.authvault.authapp.crypto

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

object EncryptionEngine {
    private const val ANDROID_KEYSTORE = "AndroidKeyStore"
    private const val KEY_ALIAS = "AuthVault_MasterKey"
    private const val AES_GCM_NOPADDING = "AES/GCM/NoPadding"
    private const val PBKDF2_HMAC_SHA256 = "PBKDF2WithHmacSHA256"
    private const val GCM_TAG_LENGTH = 128
    private const val PBKDF2_ITERATIONS = 310000
    private const val KEY_LENGTH = 256
    private const val IV_LENGTH = 12
    private const val SALT_LENGTH = 16

    data class EncryptedData(
        val ciphertext: ByteArray,
        val iv: ByteArray,
        val salt: ByteArray? = null
    ) {
        override fun equals(other: Any?): Boolean {
            if (this === other) return true
            if (javaClass != other?.javaClass) return false
            other as EncryptedData
            if (!ciphertext.contentEquals(other.ciphertext)) return false
            if (!iv.contentEquals(other.iv)) return false
            if (salt != null) {
                if (other.salt == null) return false
                if (!salt.contentEquals(other.salt)) return false
            } else if (other.salt != null) return false
            return true
        }

        override fun hashCode(): Int {
            var result = ciphertext.contentHashCode()
            result = 31 * result + iv.contentHashCode()
            result = 31 * result + (salt?.contentHashCode() ?: 0)
            return result
        }

        fun toBase64(): String {
            val parts = mutableListOf<ByteArray>()
            parts.add(iv)
            salt?.let { parts.add(it) }
            parts.add(ciphertext)
            
            return parts.joinToString(":") { Base64.encodeToString(it, Base64.NO_WRAP) }
        }

        companion object {
            fun fromBase64(encoded: String, hasSalt: Boolean = true): EncryptedData {
                val parts = encoded.split(":").map { Base64.decode(it, Base64.NO_WRAP) }
                return if (hasSalt && parts.size >= 3) {
                    EncryptedData(ciphertext = parts[2], iv = parts[0], salt = parts[1])
                } else {
                    EncryptedData(ciphertext = parts[1], iv = parts[0], salt = null)
                }
            }
        }
    }

    fun initializeKeyStore(): Boolean {
        return try {
            val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE)
            keyStore.load(null)
            
            if (!keyStore.containsAlias(KEY_ALIAS)) {
                val keyGenerator = KeyGenerator.getInstance(
                    KeyProperties.KEY_ALGORITHM_AES,
                    ANDROID_KEYSTORE
                )
                
                keyGenerator.init(
                    KeyGenParameterSpec.Builder(
                        KEY_ALIAS,
                        KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
                    )
                    .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                    .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                    .setKeySize(KEY_LENGTH)
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

    fun encryptWithMasterKey(plaintext: ByteArray): EncryptedData {
        val cipher = Cipher.getInstance(AES_GCM_NOPADDING)
        cipher.init(Cipher.ENCRYPT_MODE, getMasterKey())
        
        val iv = cipher.iv.copyOf()
        val ciphertext = cipher.doFinal(plaintext)
        
        return EncryptedData(ciphertext = ciphertext, iv = iv)
    }

    fun decryptWithMasterKey(encryptedData: EncryptedData): ByteArray {
        val cipher = Cipher.getInstance(AES_GCM_NOPADDING)
        val spec = GCMParameterSpec(GCM_TAG_LENGTH, encryptedData.iv)
        cipher.init(Cipher.DECRYPT_MODE, getMasterKey(), spec)
        
        return cipher.doFinal(encryptedData.ciphertext)
    }

    fun encryptWithPassword(plaintext: ByteArray, password: CharArray): EncryptedData {
        val salt = generateRandomBytes(SALT_LENGTH)
        val key = deriveKeyFromPassword(password, salt)
        
        val cipher = Cipher.getInstance(AES_GCM_NOPADDING)
        cipher.init(Cipher.ENCRYPT_MODE, key)
        
        val iv = cipher.iv.copyOf()
        val ciphertext = cipher.doFinal(plaintext)
        
        return EncryptedData(ciphertext = ciphertext, iv = iv, salt = salt)
    }

    fun decryptWithPassword(encryptedData: EncryptedData, password: CharArray): ByteArray {
        val salt = encryptedData.salt ?: throw IllegalArgumentException("Salt required for password decryption")
        val key = deriveKeyFromPassword(password, salt)
        
        val cipher = Cipher.getInstance(AES_GCM_NOPADDING)
        val spec = GCMParameterSpec(GCM_TAG_LENGTH, encryptedData.iv)
        cipher.init(Cipher.DECRYPT_MODE, key, spec)
        
        return cipher.doFinal(encryptedData.ciphertext)
    }

    fun generateRandomBytes(length: Int): ByteArray {
        val random = SecureRandom()
        val bytes = ByteArray(length)
        random.nextBytes(bytes)
        return bytes
    }

    private fun getMasterKey(): SecretKey {
        val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE)
        keyStore.load(null)
        return keyStore.getKey(KEY_ALIAS, null) as SecretKey
    }

    private fun deriveKeyFromPassword(password: CharArray, salt: ByteArray): SecretKey {
        val spec = PBEKeySpec(password, salt, PBKDF2_ITERATIONS, KEY_LENGTH)
        val factory = SecretKeyFactory.getInstance(PBKDF2_HMAC_SHA256)
        val keyBytes = factory.generateSecret(spec).encoded
        return SecretKeySpec(keyBytes, "AES")
    }
}
