# ============================================
# FINTELIA — ProGuard Rules for Release Build
# ============================================

# Flutter-specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep annotations
-keepattributes *Annotation*

# Dio / OkHttp networking
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Google Fonts
-keep class com.google.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Prevent R8 from stripping interface information
-keep,allowobfuscation interface * extends java.lang.annotation.Annotation { *; }

# Google Play Core (Fixes SplitCompatApplication R8 missing classes error)
-dontwarn com.google.android.play.core.**
