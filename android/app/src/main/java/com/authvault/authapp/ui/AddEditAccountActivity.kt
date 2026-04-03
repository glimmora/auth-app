package com.authvault.authapp.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.authvault.authapp.R
import com.authvault.authapp.data.Account
import com.authvault.authapp.data.AccountRepository
import com.authvault.authapp.data.AccountType
import com.authvault.authapp.crypto.HashAlgorithm
import com.google.android.material.floatingactionbutton.FloatingActionButton

class AddEditAccountActivity : AppCompatActivity() {
    
    companion object {
        const val EXTRA_ACCOUNT_ID = "account_id"
    }
    
    private lateinit var etIssuer: EditText
    private lateinit var etLabel: EditText
    private lateinit var etSecret: EditText
    private lateinit var spinnerType: Spinner
    private lateinit var spinnerAlgorithm: Spinner
    private lateinit var etDigits: EditText
    private lateinit var etPeriod: EditText
    private lateinit var etOffset: EditText
    private lateinit var etGroup: EditText
    private lateinit var switchFavorite: Switch
    private lateinit var btnSave: Button
    private lateinit var btnCancel: Button
    
    private lateinit var repository: AccountRepository
    private var editingAccountId: Long = -1
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_edit_account)
        
        repository = AccountRepository(this)
        editingAccountId = intent.getLongExtra(EXTRA_ACCOUNT_ID, -1)
        
        initViews()
        setupSpinners()
        
        if (editingAccountId != -1L) {
            loadAccountForEdit()
            btnSave.text = "Update"
        }
        
        btnSave.setOnClickListener { saveAccount() }
        btnCancel.setOnClickListener { finish() }
    }
    
    private fun initViews() {
        etIssuer = findViewById(R.id.etIssuer)
        etLabel = findViewById(R.id.etLabel)
        etSecret = findViewById(R.id.etSecret)
        spinnerType = findViewById(R.id.spinnerType)
        spinnerAlgorithm = findViewById(R.id.spinnerAlgorithm)
        etDigits = findViewById(R.id.etDigits)
        etPeriod = findViewById(R.id.etPeriod)
        etOffset = findViewById(R.id.etOffset)
        etGroup = findViewById(R.id.etGroup)
        switchFavorite = findViewById(R.id.switchFavorite)
        btnSave = findViewById(R.id.btnSave)
        btnCancel = findViewById(R.id.btnCancel)
    }
    
    private fun setupSpinners() {
        val types = arrayOf("TOTP", "HOTP", "Steam Guard")
        val algorithms = arrayOf("SHA1", "SHA256", "SHA512")
        
        val typeAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, types)
        typeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        spinnerType.adapter = typeAdapter
        
        val algoAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, algorithms)
        algoAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        spinnerAlgorithm.adapter = algoAdapter
    }
    
    private fun loadAccountForEdit() {
        val accounts = repository.getAllAccounts()
        val account = accounts.find { it.id == editingAccountId } ?: return
        
        etIssuer.setText(account.issuer)
        etLabel.setText(account.label)
        etSecret.setText(account.secret)
        spinnerType.setSelection(account.type.ordinal)
        spinnerAlgorithm.setSelection(account.algorithm.ordinal)
        etDigits.setText(account.digits.toString())
        etPeriod.setText(account.period.toString())
        etOffset.setText(account.offset.toString())
        etGroup.setText(account.group ?: "")
        switchFavorite.isChecked = account.isFavorite
    }
    
    private fun saveAccount() {
        val issuer = etIssuer.text.toString().trim()
        val label = etLabel.text.toString().trim()
        val secret = etSecret.text.toString().trim()
        
        if (issuer.isEmpty() || label.isEmpty() || secret.isEmpty()) {
            Toast.makeText(this, "Please fill all required fields", Toast.LENGTH_SHORT).show()
            return
        }
        
        val type = AccountType.values()[spinnerType.selectedItemPosition]
        val algorithm = HashAlgorithm.values()[spinnerAlgorithm.selectedItemPosition]
        val digits = etDigits.text.toString().toIntOrNull() ?: 6
        val period = etPeriod.text.toString().toIntOrNull() ?: 30
        val offset = etOffset.text.toString().toIntOrNull() ?: 0
        val group = etGroup.text.toString().trim().ifEmpty { null }
        val isFavorite = switchFavorite.isChecked
        
        val account = Account(
            id = editingAccountId,
            issuer = issuer,
            label = label,
            secret = secret,
            type = type,
            algorithm = algorithm,
            digits = digits,
            period = period,
            offset = offset,
            group = group,
            isFavorite = isFavorite
        )
        
        if (editingAccountId == -1L) {
            repository.insertAccount(account)
            Toast.makeText(this, "Account added", Toast.LENGTH_SHORT).show()
        } else {
            repository.updateAccount(account)
            Toast.makeText(this, "Account updated", Toast.LENGTH_SHORT).show()
        }
        
        finish()
    }
}
