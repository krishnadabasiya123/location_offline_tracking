import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
android {
    namespace = "com.omkar.sale"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion


  // Print the SDK versions for debugging
    val compileSdkVer = flutter.compileSdkVersion
    val targetSdkVer = flutter.targetSdkVersion
    val minSdkVer = flutter.minSdkVersion
    val ndkVer = flutter.ndkVersion
    
    println("=== Flutter SDK Versions ===")
    println("compileSdkVersion: $compileSdkVer")
    println("targetSdkVersion: $targetSdkVer") 
    println("minSdkVersion: $minSdkVer")
    println("ndkVersion: $ndkVer")
    println("============================")
    


    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // okhttp-tls and jspecify both ship META-INF/versions/9/OSGI-INF/MANIFEST.MF.
    // pickFirsts resolves the duplicate without affecting runtime.
    packaging {
        resources {
            pickFirsts += setOf(
                "META-INF/versions/9/OSGI-INF/MANIFEST.MF",
            )
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.omkar.sale"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // tracelet_android requires minSdk 26 (Android 8.0 / Oreo).
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as? String
            keyPassword = keystoreProperties["keyPassword"] as? String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as? String
        }
    }
buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            //signingConfig = signingConfigs.getByName("release")
            signingConfig = signingConfigs.getByName("release") 
               isMinifyEnabled = true
            
 
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
            
        }
    }
}

flutter {
    source = "../.."
}
// Exclude legacy support library — entire project uses AndroidX.
// Kept as a safety net in case any transitive Android dep still pulls
// com.android.support:* which would duplicate classes in androidx.core.
configurations.all {
    exclude(group = "com.android.support")
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-messaging")
    implementation("com.google.firebase:firebase-core:16.0.9")
}
