# ==============================================================================
# Rules for uCrop (Image Cropping Library)
# ==============================================================================
-keep class com.yalantis.ucrop** { *; }
-keep interface com.yalantis.ucrop** { *; }

# Ignore warnings for okhttp/okio if they are dependencies of ucrop but not used directly by the app
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn com.yalantis.ucrop.task.BitmapLoadTask

# ==============================================================================
# Generic Rules for Annotations and Signatures
# ==============================================================================
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

# ==============================================================================
# Rules for Gson (JSON Serialization Library)
# These rules ensure that fields annotated with @SerializedName, TypeAdapters, 
# and TypeToken classes are not stripped or obfuscated.
# ==============================================================================

# Keep TypeAdapters, TypeAdapterFactories, Serializers, and Deserializers
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep fields annotated with @SerializedName so Gson can find them
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Keep the TypeToken hierarchy
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
