package com.authvault.authapp

import android.app.Application
import android.content.Context

class AuthVaultApp : Application() {
    companion object {
        private lateinit var instance: AuthVaultApp
        
        fun getInstance(): AuthVaultApp {
            return instance
        }
        
        fun getAppContext(): Context {
            return instance.applicationContext
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        instance = this
    }
}
