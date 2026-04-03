package com.authvault.authapp.data

import com.authvault.authapp.crypto.HashAlgorithm
import com.authvault.authapp.crypto.OtpParameters
import com.authvault.authapp.crypto.TotpEngine

enum class AccountType {
    TOTP, HOTP, STEAM
}

data class Account(
    val id: Long = 0,
    val issuer: String,
    val label: String,
    val secret: String,
    val type: AccountType = AccountType.TOTP,
    val algorithm: HashAlgorithm = HashAlgorithm.SHA1,
    val digits: Int = 6,
    val period: Int = 30,
    val counter: Long = 0,
    val offset: Int = 0,
    val icon: String? = null,
    val color: Int? = null,
    val group: String? = null,
    val tags: List<String> = emptyList(),
    val isFavorite: Boolean = false,
    val position: Int = 0,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
) {
    fun getCurrentCode(): String {
        val params = OtpParameters(
            secret = secret,
            algorithm = algorithm,
            digits = digits,
            period = period,
            counter = counter,
            offset = offset
        )
        
        return when (type) {
            AccountType.TOTP -> TotpEngine.generateTOTP(params)
            AccountType.HOTP -> TotpEngine.generateHOTP(params)
            AccountType.STEAM -> TotpEngine.generateSteamGuard(params)
        }
    }
}
