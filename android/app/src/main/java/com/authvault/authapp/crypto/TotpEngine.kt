package com.authvault.authapp.crypto

import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec
import java.security.InvalidKeyException
import java.security.NoSuchAlgorithmException

object TotpEngine {
    private const val TOTP_PERIOD = 30
    private const val TOTP_DIGITS = 6

    fun generate(secret: String, time: Long = System.currentTimeMillis() / 1000): String {
        val decodedSecret = Base32.decode(secret)
        val counter = time / TOTP_PERIOD
        return generateHotp(decodedSecret, counter, TOTP_DIGITS)
    }

    private fun generateHotp(key: ByteArray, counter: Long, digits: Int): String {
        val hash = hmacSha1(key, longToBytes(counter))
        val offset = hash[hash.size - 1].toInt() and 0x0F
        val binaryCode = ((hash[offset].toInt() and 0x7F) shl 24) or
                ((hash[offset + 1].toInt() and 0xFF) shl 16) or
                ((hash[offset + 2].toInt() and 0xFF) shl 8) or
                (hash[offset + 3].toInt() and 0xFF)

        val otp = binaryCode % Math.pow(10.0, digits.toDouble()).toInt()
        return String.format("%0${digits}d", otp)
    }

    private fun hmacSha1(key: ByteArray, data: ByteArray): ByteArray {
        return try {
            val mac = Mac.getInstance("HmacSHA1")
            mac.init(SecretKeySpec(key, "HmacSHA1"))
            mac.doFinal(data)
        } catch (e: NoSuchAlgorithmException) {
            throw RuntimeException("HmacSHA1 not available", e)
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
