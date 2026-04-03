package com.authvault.authapp

import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import com.authvault.authapp.data.Account
import com.authvault.authapp.data.AccountRepository
import com.authvault.authapp.data.AccountType
import com.authvault.authapp.crypto.EncryptionEngine
import com.authvault.authapp.crypto.HashAlgorithm
import com.authvault.authapp.databinding.ActivityMainBinding
import com.authvault.authapp.ui.AccountAdapter
import com.authvault.authapp.ui.AddEditAccountActivity
import com.google.android.material.floatingactionbutton.FloatingActionButton
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var repository: AccountRepository
    private lateinit var adapter: AccountAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        AppContext.init(this)
        
        // Prevent screenshots and screen recording
        window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
        
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        // Initialize encryption engine
        EncryptionEngine.initializeKeyStore()
        
        repository = AccountRepository(this)
        
        adapter = AccountAdapter(this) { account ->
            // Handle account click - could show details or copy code
        }
        
        binding.recyclerView.layoutManager = LinearLayoutManager(this)
        binding.recyclerView.adapter = adapter
        
        val fab = findViewById<FloatingActionButton>(R.id.fabAddAccount)
        fab.setOnClickListener {
            val intent = Intent(this, AddEditAccountActivity::class.java)
            startActivity(intent)
        }
        
        loadAccounts()
        
        // Demo - add test account if empty
        if (repository.getAllAccounts().isEmpty()) {
            CoroutineScope(Dispatchers.IO).launch {
                val testAccount = Account(
                    issuer = "GitHub",
                    label = "user@example.com",
                    secret = "JBSWY3DPEHPK3PXP",
                    type = AccountType.TOTP,
                    algorithm = HashAlgorithm.SHA1,
                    digits = 6,
                    period = 30
                )
                repository.insertAccount(testAccount)
                
                val steamAccount = Account(
                    issuer = "Steam",
                    label = "steam_user",
                    secret = "JBSWY3DPEHPK3PXP",
                    type = AccountType.STEAM,
                    algorithm = HashAlgorithm.SHA1,
                    digits = 5,
                    period = 30
                )
                repository.insertAccount(steamAccount)
                
                withContext(Dispatchers.Main) {
                    loadAccounts()
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        loadAccounts()
    }

    private fun loadAccounts() {
        CoroutineScope(Dispatchers.IO).launch {
            val accounts = repository.getAllAccounts()
            withContext(Dispatchers.Main) {
                adapter.submitList(accounts)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clear all timers
        binding.recyclerView.adapter = null
    }
}
