# Most Flutter plugins bundle their own consumer proguard rules inside
# their AAR, which R8 picks up automatically — nothing needed here for
# those. flutter_local_notifications (used for expiration reminders,
# ARCHITECTURE.md §10) is the one exception found in this project:
# checked its source directly (v22.1.0) and confirmed it still serializes
# scheduled-reminder data via Gson for restoring exact/inexact alarms
# after a device reboot, and does not ship its own consumer-rules.pro.
# Gson's generic-type reflection is a classic R8-shrinking casualty —
# without these, reminders could silently fail to survive a reboot in a
# release build specifically (this wouldn't show up in a debug build,
# since minification is release-only).
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class com.google.gson.reflect.TypeToken { *; }
-dontwarn com.google.gson.**
