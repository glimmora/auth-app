package com.authvault.authapp.crypto

object Base32 {
    private const val BASE32_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

    fun decode(encoded: String): ByteArray {
        val encodedUpper = encoded.uppercase().replace("=", "")
        var buffer = 0L
        var bitsLeft = 0
        val result = mutableListOf<Byte>()

        for (c in encodedUpper) {
            val index = BASE32_CHARS.indexOf(c)
            if (index == -1) throw IllegalArgumentException("Invalid Base32 character: $c")
            buffer = (buffer shl 5) or index.toLong()
            bitsLeft += 5
            if (bitsLeft >= 8) {
                bitsLeft -= 8
                result.add((buffer shr bitsLeft).toByte())
            }
        }
        return result.toByteArray()
    }
}
