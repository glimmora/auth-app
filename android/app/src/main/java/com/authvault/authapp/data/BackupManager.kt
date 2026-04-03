package com.authvault.authapp.data

import android.content.Context
import java.io.*
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream
import java.util.zip.ZipOutputStream

object BackupManager {
    private const val AVX_MAGIC = "AUTHVAULT"
    private const val AVX_VERSION = 1
    
    data class BackupResult(
        val success: Boolean,
        val message: String,
        val accountCount: Int = 0
    )
    
    fun exportToAvx(context: Context, accounts: List<Account>, outputPath: String, password: String): BackupResult {
        return try {
            val outputStream = FileOutputStream(outputPath)
            val zipOutputStream = ZipOutputStream(BufferedOutputStream(outputStream))
            
            zipOutputStream.putNextEntry(ZipEntry("manifest.json"))
            val manifest = """{"version":$AVX_VERSION,"count":${accounts.size},"magic":"$AVX_MAGIC"}"""
            zipOutputStream.write(manifest.toByteArray())
            zipOutputStream.closeEntry()
            
            val accountsJson = accounts.joinToString(",", "[", "]") { account ->
                """{"issuer":"${account.issuer}","label":"${account.label}","secret":"${account.secret}","type":${account.type.ordinal},"algorithm":${account.algorithm.ordinal},"digits":${account.digits},"period":${account.period},"counter":${account.counter},"offset":${account.offset}}"""
            }
            
            zipOutputStream.putNextEntry(ZipEntry("accounts.json"))
            zipOutputStream.write(accountsJson.toByteArray())
            zipOutputStream.closeEntry()
            
            zipOutputStream.close()
            outputStream.close()
            
            BackupResult(true, "Backup berhasil: ${accounts.size} akun", accounts.size)
        } catch (e: Exception) {
            BackupResult(false, "Gagal backup: ${e.message}")
        }
    }
    
    fun importFromAvx(context: Context, inputPath: String, password: String): BackupResult {
        return try {
            val inputStream = FileInputStream(inputPath)
            val zipInputStream = ZipInputStream(BufferedInputStream(inputStream))
            
            var accountsJson: String? = null
            var manifestJson: String? = null
            
            var entry: ZipEntry?
            while (zipInputStream.nextEntry.also { entry = it } != null) {
                val content = zipInputStream.readBytes().decodeToString()
                when (entry?.name) {
                    "manifest.json" -> manifestJson = content
                    "accounts.json" -> accountsJson = content
                }
                zipInputStream.closeEntry()
            }
            
            zipInputStream.close()
            inputStream.close()
            
            if (accountsJson == null || manifestJson == null) {
                return BackupResult(false, "File backup rusak atau tidak valid")
            }
            
            val accounts = parseAccountsJson(accountsJson)
            BackupResult(true, "Import berhasil: ${accounts.size} akun", accounts.size)
        } catch (e: Exception) {
            BackupResult(false, "Gagal import: ${e.message}")
        }
    }
    
    private fun parseAccountsJson(json: String): List<Account> {
        val accounts = mutableListOf<Account>()
        return accounts
    }
}
