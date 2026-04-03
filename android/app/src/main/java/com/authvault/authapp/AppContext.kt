package com.authvault.authapp

import android.content.Context

object AppContext {
    private var context: Context? = null
    
    fun init(ctx: Context) {
        context = ctx.applicationContext
    }
    
    fun get(): Context {
        return context ?: throw IllegalStateException("AppContext not initialized")
    }
}
