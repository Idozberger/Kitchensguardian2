# Flutter / engine
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

# Gson / JSON (used by several plugins)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}


# Keep Google Play Services and AdMob classes
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# Prevent obfuscation of javascript interfaces used by ads
-keepattributes JavascriptInterface
-keepattributes *Annotation*

# Firebase / Play services (avoid noisy warnings; keep public APIs plugins need)
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# OkHttp / Dio stack (if R8 strips platform classes)
-dontwarn okhttp3.**
-dontwarn okio.**

# Play Core (optional paths / older APIs; keep R8 quiet if referenced reflectively)
-dontwarn com.google.android.play.core.**
