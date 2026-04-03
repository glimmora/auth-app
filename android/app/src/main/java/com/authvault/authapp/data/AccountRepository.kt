package com.authvault.authapp.data

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import com.authvault.authapp.crypto.EncryptionEngine
import com.authvault.authapp.crypto.HashAlgorithm

class AccountRepository(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_NAME = "authvault.db"
        private const val DATABASE_VERSION = 1
        
        private const val TABLE_ACCOUNTS = "accounts"
        private const val COLUMN_ID = "_id"
        private const val COLUMN_ISSUER = "issuer"
        private const val COLUMN_LABEL = "label"
        private const val COLUMN_SECRET = "secret"
        private const val COLUMN_TYPE = "type"
        private const val COLUMN_ALGORITHM = "algorithm"
        private const val COLUMN_DIGITS = "digits"
        private const val COLUMN_PERIOD = "period"
        private const val COLUMN_COUNTER = "counter"
        private const val COLUMN_OFFSET = "offset"
        private const val COLUMN_ICON = "icon"
        private const val COLUMN_COLOR = "color"
        private const val COLUMN_GROUP = "group_name"
        private const val COLUMN_TAGS = "tags"
        private const val COLUMN_FAVORITE = "is_favorite"
        private const val COLUMN_POSITION = "position"
        private const val COLUMN_CREATED_AT = "created_at"
        private const val COLUMN_UPDATED_AT = "updated_at"
    }

    override fun onCreate(db: SQLiteDatabase) {
        val createTable = """
            CREATE TABLE $TABLE_ACCOUNTS (
                $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COLUMN_ISSUER TEXT NOT NULL,
                $COLUMN_LABEL TEXT NOT NULL,
                $COLUMN_SECRET TEXT NOT NULL,
                $COLUMN_TYPE INTEGER NOT NULL DEFAULT 0,
                $COLUMN_ALGORITHM INTEGER NOT NULL DEFAULT 0,
                $COLUMN_DIGITS INTEGER NOT NULL DEFAULT 6,
                $COLUMN_PERIOD INTEGER NOT NULL DEFAULT 30,
                $COLUMN_COUNTER INTEGER NOT NULL DEFAULT 0,
                $COLUMN_OFFSET INTEGER NOT NULL DEFAULT 0,
                $COLUMN_ICON TEXT,
                $COLUMN_COLOR INTEGER,
                $COLUMN_GROUP TEXT,
                $COLUMN_TAGS TEXT,
                $COLUMN_FAVORITE INTEGER NOT NULL DEFAULT 0,
                $COLUMN_POSITION INTEGER NOT NULL DEFAULT 0,
                $COLUMN_CREATED_AT INTEGER NOT NULL,
                $COLUMN_UPDATED_AT INTEGER NOT NULL
            )
        """.trimIndent()
        db.execSQL(createTable)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS $TABLE_ACCOUNTS")
        onCreate(db)
    }

    fun insertAccount(account: Account): Long {
        val encryptedSecret = EncryptionEngine.encryptWithMasterKey(account.secret.toByteArray())
        
        val values = ContentValues().apply {
            put(COLUMN_ISSUER, account.issuer)
            put(COLUMN_LABEL, account.label)
            put(COLUMN_SECRET, encryptedSecret.toBase64())
            put(COLUMN_TYPE, account.type.ordinal)
            put(COLUMN_ALGORITHM, account.algorithm.ordinal)
            put(COLUMN_DIGITS, account.digits)
            put(COLUMN_PERIOD, account.period)
            put(COLUMN_COUNTER, account.counter)
            put(COLUMN_OFFSET, account.offset)
            put(COLUMN_ICON, account.icon)
            put(COLUMN_COLOR, account.color)
            put(COLUMN_GROUP, account.group)
            put(COLUMN_TAGS, account.tags.joinToString(","))
            put(COLUMN_FAVORITE, if (account.isFavorite) 1 else 0)
            put(COLUMN_POSITION, account.position)
            put(COLUMN_CREATED_AT, account.createdAt)
            put(COLUMN_UPDATED_AT, account.updatedAt)
        }
        
        return writableDatabase.insert(TABLE_ACCOUNTS, null, values)
    }

    fun getAllAccounts(): List<Account> {
        val accounts = mutableListOf<Account>()
        val cursor = readableDatabase.query(
            TABLE_ACCOUNTS,
            null,
            null,
            null,
            null,
            null,
            "$COLUMN_POSITION ASC, $COLUMN_CREATED_AT DESC"
        )
        
        with(cursor) {
            while (moveToNext()) {
                val encryptedSecret = EncryptionEngine.EncryptedData.fromBase64(
                    getString(getColumnIndexOrThrow(COLUMN_SECRET)),
                    hasSalt = false
                )
                val secret = EncryptionEngine.decryptWithMasterKey(encryptedSecret).decodeToString()
                
                accounts.add(Account(
                    id = getLong(getColumnIndexOrThrow(COLUMN_ID)),
                    issuer = getString(getColumnIndexOrThrow(COLUMN_ISSUER)),
                    label = getString(getColumnIndexOrThrow(COLUMN_LABEL)),
                    secret = secret,
                    type = AccountType.values()[getInt(getColumnIndexOrThrow(COLUMN_TYPE))],
                    algorithm = HashAlgorithm.values()[getInt(getColumnIndexOrThrow(COLUMN_ALGORITHM))],
                    digits = getInt(getColumnIndexOrThrow(COLUMN_DIGITS)),
                    period = getInt(getColumnIndexOrThrow(COLUMN_PERIOD)),
                    counter = getLong(getColumnIndexOrThrow(COLUMN_COUNTER)),
                    offset = getInt(getColumnIndexOrThrow(COLUMN_OFFSET)),
                    icon = getString(getColumnIndexOrThrow(COLUMN_ICON)),
                    color = if (isNull(getColumnIndexOrThrow(COLUMN_COLOR))) null else getInt(getColumnIndexOrThrow(COLUMN_COLOR)),
                    group = getString(getColumnIndexOrThrow(COLUMN_GROUP)),
                    tags = getString(getColumnIndexOrThrow(COLUMN_TAGS))?.split(",") ?: emptyList(),
                    isFavorite = getInt(getColumnIndexOrThrow(COLUMN_FAVORITE)) == 1,
                    position = getInt(getColumnIndexOrThrow(COLUMN_POSITION)),
                    createdAt = getLong(getColumnIndexOrThrow(COLUMN_CREATED_AT)),
                    updatedAt = getLong(getColumnIndexOrThrow(COLUMN_UPDATED_AT))
                ))
            }
            close()
        }
        
        return accounts
    }

    fun deleteAccount(id: Long): Int {
        return writableDatabase.delete(TABLE_ACCOUNTS, "$COLUMN_ID = ?", arrayOf(id.toString()))
    }

    fun updateAccount(account: Account): Int {
        val encryptedSecret = EncryptionEngine.encryptWithMasterKey(account.secret.toByteArray())
        
        val values = ContentValues().apply {
            put(COLUMN_ISSUER, account.issuer)
            put(COLUMN_LABEL, account.label)
            put(COLUMN_SECRET, encryptedSecret.toBase64())
            put(COLUMN_TYPE, account.type.ordinal)
            put(COLUMN_ALGORITHM, account.algorithm.ordinal)
            put(COLUMN_DIGITS, account.digits)
            put(COLUMN_PERIOD, account.period)
            put(COLUMN_COUNTER, account.counter)
            put(COLUMN_OFFSET, account.offset)
            put(COLUMN_ICON, account.icon)
            put(COLUMN_COLOR, account.color)
            put(COLUMN_GROUP, account.group)
            put(COLUMN_TAGS, account.tags.joinToString(","))
            put(COLUMN_FAVORITE, if (account.isFavorite) 1 else 0)
            put(COLUMN_POSITION, account.position)
            put(COLUMN_UPDATED_AT, System.currentTimeMillis())
        }
        
        return writableDatabase.update(
            TABLE_ACCOUNTS,
            values,
            "$COLUMN_ID = ?",
            arrayOf(account.id.toString())
        )
    }
}
