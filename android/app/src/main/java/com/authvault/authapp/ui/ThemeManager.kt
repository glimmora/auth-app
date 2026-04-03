package com.authvault.authapp.ui

import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.view.View
import android.view.WindowInsetsController
import androidx.appcompat.app.AppCompatDelegate

object ThemeManager {
    private const val PREFS_NAME = "theme_prefs"
    private const val KEY_THEME = "theme_mode"
    
    enum class ThemeMode {
        LIGHT, DARK, AMOLED, SYSTEM
    }
    
    fun setTheme(context: Context, theme: ThemeMode) {
        getPrefs(context).edit().putString(KEY_THEME, theme.name).apply()
        applyTheme(context, theme)
    }
    
    fun getTheme(context: Context): ThemeMode {
        val name = getPrefs(context).getString(KEY_THEME, ThemeMode.SYSTEM.name)
        return ThemeMode.valueOf(name ?: ThemeMode.SYSTEM.name)
    }
    
    fun applyTheme(context: Context, theme: ThemeMode) {
        when (theme) {
            ThemeMode.LIGHT -> AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
            ThemeMode.DARK -> AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES)
            ThemeMode.AMOLED -> {
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    val window = (context as? android.app.Activity)?.window
                    window?.decorView?.windowInsetsController?.setSystemBarsAppearance(
                        WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS,
                        WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS
                    )
                }
            }
            ThemeMode.SYSTEM -> AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM)
        }
    }
    
    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }
}
