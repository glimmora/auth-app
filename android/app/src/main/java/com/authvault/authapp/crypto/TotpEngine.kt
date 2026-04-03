package com.authvault.authapp.crypto

import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec
import java.security.InvalidKeyException
import java.security.NoSuchAlgorithmException
import kotlin.math.pow

enum class HashAlgorithm {
    SHA1, SHA256, SHA512
}

data class OtpParameters(
    val secret: String,
    val algorithm: HashAlgorithm = HashAlgorithm.SHA1,
    val digits: Int = 6,
    val period: Int = 30,
    val counter: Long = 0,
    val offset: Int = 0
)

object TotpEngine {
    private const val STEAM_ALPHABET = "23456789BCDFGHJKMNPQRTVWXY"

    fun generateTOTP(params: OtpParameters, time: Long = System.currentTimeMillis() / 1000): String {
        val adjustedTime = time + params.offset
        val counter = adjustedTime / params.period
        return generateHOTP(params.copy(counter = counter))
    }

    fun generateHOTP(params: OtpParameters): String {
        val decodedSecret = Base32.decode(params.secret)
        val counterBytes = longToBytes(params.counter)
        val hash = hmac(decodedSecret, counterBytes, params.algorithm)
        
        val offset = hash[hash.size - 1].toInt() and 0x0F
        val binaryCode = ((hash[offset].toInt() and 0x7F) shl 24) or
                ((hash[offset + 1].toInt() and 0xFF) shl 16) or
                ((hash[offset + 2].toInt() and 0xFF) shl 8) or
                (hash[offset + 3].toInt() and 0xFF)

        val otp = binaryCode % (10.0.pow(params.digits)).toInt()
        return String.format("%0${params.digits}d", otp)
    }

    fun generateSteamGuard(params: OtpParameters, time: Long = System.currentTimeMillis() / 1000): String {
        val adjustedTime = time + params.offset
        val counter = adjustedTime / 30
        val decodedSecret = Base32.decode(params.secret)
        val counterBytes = longToBytes(counter)
        val hash = hmac(decodedSecret, counterBytes, HashAlgorithm.SHA1)
        
        val offset = hash[hash.size - 1].toInt() and 0x0F
        var fullCode = ((hash[offset].toInt() and 0x7F) shl 24) or
                ((hash[offset + 1].toInt() and 0xFF) shl 16) or
                ((hash[offset + 2].toInt() and 0xFF) shl 8) or
                (hash[offset + 3].toInt() and 0xFF)

        return buildString {
            for (i in 0 until 5) {
                append(STEAM_ALPHABET[fullCode % STEAM_ALPHABET.length])
                fullCode /= STEAM_ALPHABET.length
            }
        }
    }

    fun getRemainingSeconds(period: Int = 30, time: Long = System.currentTimeMillis() / 1000): Int {
        return period - (time % period).toInt()
    }

    private fun hmac(key: ByteArray, data: ByteArray, algorithm: HashAlgorithm): ByteArray {
        val algorithmName = when (algorithm) {
            HashAlgorithm.SHA1 -> "HmacSHA1"
            HashAlgorithm.SHA256 -> "HmacSHA256"
            HashAlgorithm.SHA512 -> "HmacSHA512"
        }
        
        return try {
            val mac = Mac.getInstance(algorithmName)
            mac.init(SecretKeySpec(key, algorithmName))
            mac.doFinal(data)
        } catch (e: NoSuchAlgorithmException) {
            throw RuntimeException("$algorithmName not available", e)
        } catch (e: InvalidKeyException) {
            throw RuntimeException("Invalid key", e)
        }
    }

    private fun longToBytes(value: Long): ByteArray {
        val result = ByteArray(8)
        for (i in 7 downTo 0) {
            result[i] = (value and 0xFF).toByte()
        }
        return result
    }
}
