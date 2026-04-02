# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Drift / SQLite
-keep class com.almworks.sqlite4java.** { *; }
-dontwarn com.almworks.sqlite4java.**
-keep class org.sqlite.** { *; }
-dontwarn org.sqlite.**

# Cryptography
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# Keep annotation
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# mobile_scanner / zxing / ML Kit
-keep class com.google.zxing.** { *; }
-dontwarn com.google.zxing.**
-keep class com.journeyapps.barcodescanner.** { *; }
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Keep models
-keep class app.authvault.** { *; }

# Google Play Core / Feature Delivery
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.finsky.** { *; }
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.finsky.**

# local_auth
-keep class androidx.biometric.** { *; }
-dontwarn androidx.biometric.**

# file_picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-dontwarn com.mr.flutter.plugin.filepicker.**

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# share_plus
-keep class dev.fluttercommunity.plus.share.** { *; }
-dontwarn dev.fluttercommunity.plus.share.**

# url_launcher
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# flutter_local_notifications
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# home_widget
-keep class es.antonborri.home_widget.** { *; }
-dontwarn es.antonborri.home_widget.**

# image_picker
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.imagepicker.**

# General Android rules
-dontwarn kotlin.**
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# Keep enum ordinal values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Freezed/JSON serialization
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keep class * implements java.io.Serializable { *; }
