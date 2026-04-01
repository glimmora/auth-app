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

# Cryptography
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# Keep annotation
-keepattributes *Annotation*
-keepattributes Signature

# mobile_scanner / zxing
-keep class com.google.zxing.** { *; }
-dontwarn com.google.zxing.**
-keep class com.journeyapps.barcodescanner.** { *; }

# Keep models
-keep class app.authvault.** { *; }

# General Android rules
-dontwarn kotlin.**
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
