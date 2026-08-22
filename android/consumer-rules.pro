# Google Play Core In-App Update library
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.appupdate.** { *; }
-keep class com.google.android.play.core.install.** { *; }

# Play Core transitive dependencies
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.assetpacks.** { *; }

-dontwarn com.google.android.play.core.**


# Plugin classes
-keep class in_app_update_android.** { *; }
-keepclassmembers class in_app_update_android.** { *; }