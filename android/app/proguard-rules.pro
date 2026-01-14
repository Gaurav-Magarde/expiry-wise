# Flutter & Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn io.flutter.embedding.**

# Attributes
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# 🔥 GSON FIX (Ab ye chalega kyuki humne dependency add kar di hai)
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-dontwarn com.google.gson.**

-ignorewarnings