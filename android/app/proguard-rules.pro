# ─── Flutter ──────────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ─── Isar (uses native code + reflection) ────────────────────────────────────
-keep class dev.isar.** { *; }
-keep class com.isar.** { *; }
-keep @interface dev.isar.isar.annotation.** { *; }
# Keep all Isar-generated schema classes
-keep class ** implements dev.isar.isar.IsarObject { *; }
-keepclassmembers class ** {
    @dev.isar.isar.annotation.* <fields>;
}

# ─── Google Mobile Ads ────────────────────────────────────────────────────────
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# ─── AndroidX WorkManager (used by flutter_local_notifications) ───────────────
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker { *; }
-keep class androidx.work.impl.** { *; }
-keep class androidx.work.impl.model.** { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
-keep @androidx.room.Database class * { *; }
-dontwarn androidx.work.**

# ─── AndroidX Startup (InitializationProvider) ───────────────────────────────
-keep class androidx.startup.** { *; }
-keep class * implements androidx.startup.Initializer { *; }
-keepnames class androidx.startup.InitializationProvider
-dontwarn androidx.startup.**

# ─── Flutter Local Notifications ─────────────────────────────────────────────
-keep class com.dexterous.** { *; }

# ─── Flutter TTS ─────────────────────────────────────────────────────────────
-keep class com.tundralabs.** { *; }

# ─── Shared Preferences ──────────────────────────────────────────────────────
-keep class androidx.datastore.** { *; }

# ─── Kotlin ──────────────────────────────────────────────────────────────────
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**

# ─── Serialization (freezed/json_serializable) ───────────────────────────────
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
-keep class * implements java.io.Serializable { *; }

# ─── General safety rules ────────────────────────────────────────────────────
-keepattributes InnerClasses
-keep class **.R
-keep class **.R$* { *; }
