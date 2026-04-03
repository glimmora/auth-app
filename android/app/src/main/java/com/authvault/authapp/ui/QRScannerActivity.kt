package com.authvault.authapp.ui

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.view.View
import android.widget.*
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.authvault.authapp.R
import com.authvault.authapp.data.AccountRepository
import com.authvault.authapp.data.AccountType
import com.authvault.authapp.crypto.HashAlgorithm
import com.google.zxing.BarcodeFormat
import com.google.zxing.BinaryBitmap
import com.google.zxing.MultiFormatReader
import com.google.zxing.RGBLuminanceSource
import com.google.zxing.common.HybridBinarizer
import java.io.IOException

class QRScannerActivity : AppCompatActivity() {

    companion object {
        private const val REQUEST_CAMERA = 100
    }

    private lateinit var repository: AccountRepository
    private var isProcessing = false

    private val cameraLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == RESULT_OK) {
            val bitmap = result.data?.extras?.get("data") as? Bitmap
            bitmap?.let { processQRCode(it) }
        }
    }

    private val galleryLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == RESULT_OK) {
            val uri = result.data?.data
            uri?.let { processImageFromGallery(it) }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_qr_scanner)

        repository = AccountRepository(this)

        findViewById<Button>(R.id.btnScanQR).setOnClickListener {
            checkCameraPermission()
        }

        findViewById<Button>(R.id.btnImportImage).setOnClickListener {
            galleryLauncher.launch(Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI))
        }

        findViewById<Button>(R.id.btnManualEntry).setOnClickListener {
            finish()
        }
    }

    private fun checkCameraPermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
            openCamera()
        } else {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), REQUEST_CAMERA)
        }
    }

    private fun openCamera() {
        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        cameraLauncher.launch(intent)
    }

    private fun processImageFromGallery(uri: Uri) {
        try {
            val bitmap = MediaStore.Images.Media.getBitmap(contentResolver, uri)
            processQRCode(bitmap)
        } catch (e: IOException) {
            e.printStackTrace()
            Toast.makeText(this, "Failed to load image", Toast.LENGTH_SHORT).show()
        }
    }

    private fun processQRCode(bitmap: Bitmap) {
        if (isProcessing) return
        isProcessing = true

        try {
            val intArray = IntArray(bitmap.width * bitmap.height)
            bitmap.getPixels(intArray, 0, bitmap.width, 0, 0, bitmap.width, bitmap.height)

            val source = RGBLuminanceSource(bitmap.width, bitmap.height, intArray)
            val binaryBitmap = BinaryBitmap(HybridBinarizer(source))
            val reader = MultiFormatReader()
            val result = reader.decode(binaryBitmap)

            val text = result.text
            parseOtpAuthUrl(text)
        } catch (e: Exception) {
            e.printStackTrace()
            Toast.makeText(this, "QR code tidak valid atau tidak terdeteksi", Toast.LENGTH_LONG).show()
        } finally {
            isProcessing = false
        }
    }

    private fun parseOtpAuthUrl(url: String) {
        try {
            val uri = Uri.parse(url)
            
            if (uri.scheme != "otpauth") {
                Toast.makeText(this, "Invalid OTP auth URL", Toast.LENGTH_SHORT).show()
                return
            }

            val type = uri.authority
            val label = uri.path?.trimStart('/') ?: ""
            val parts = label.split(":")
            val issuer = parts.getOrNull(0) ?: ""
            val accountLabel = parts.getOrNull(1) ?: ""

            val secret = uri.getQueryParameter("secret") ?: ""
            val algorithm = uri.getQueryParameter("algorithm") ?: "SHA1"
            val digits = uri.getQueryParameter("digits")?.toIntOrNull() ?: 6
            val period = uri.getQueryParameter("period")?.toIntOrNull() ?: 30
            val counter = uri.getQueryParameter("counter")?.toLongOrNull() ?: 0

            if (secret.isEmpty()) {
                Toast.makeText(this, "Secret key tidak ditemukan", Toast.LENGTH_SHORT).show()
                return
            }

            val accountType = when (type) {
                "totp" -> AccountType.TOTP
                "hotp" -> AccountType.HOTP
                "steam" -> AccountType.STEAM
                else -> {
                    Toast.makeText(this, "Tipe OTP tidak didukung: $type", Toast.LENGTH_SHORT).show()
                    return
                }
            }

            val hashAlgo = when (algorithm.uppercase()) {
                "SHA256" -> HashAlgorithm.SHA256
                "SHA512" -> HashAlgorithm.SHA512
                else -> HashAlgorithm.SHA1
            }

            val account = com.authvault.authapp.data.Account(
                issuer = issuer,
                label = accountLabel,
                secret = secret,
                type = accountType,
                algorithm = hashAlgo,
                digits = digits,
                period = if (accountType == AccountType.HOTP) 0 else period,
                counter = counter
            )

            repository.insertAccount(account)
            Toast.makeText(this, "Akun berhasil ditambahkan: $issuer", Toast.LENGTH_LONG).show()
            finish()

        } catch (e: Exception) {
            e.printStackTrace()
            Toast.makeText(this, "Gagal memparse otpauth URL", Toast.LENGTH_SHORT).show()
        }
    }
}
