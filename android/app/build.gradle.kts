import java.io.File
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// This module is android/app — parent is always android/ (regardless of Gradle rootProject).
val androidDir: File = project.projectDir.parentFile!!

val keystoreProperties = Properties()
val keystorePropertiesFile = File(androidDir, "key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.itz.kitchens.guardian"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {        
       isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.itz.kitchens.guardian"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                val storePath = requireNotNull(keystoreProperties.getProperty("storeFile")) {
                    "key.properties: storeFile is required"
                }
                // Paths are relative to android/ (where key.properties lives)
                storeFile = File(androidDir, storePath).normalize()
                keyAlias = requireNotNull(keystoreProperties.getProperty("keyAlias")) {
                    "key.properties: keyAlias is required"
                }
                keyPassword = requireNotNull(keystoreProperties.getProperty("keyPassword")) {
                    "key.properties: keyPassword is required"
                }
                storePassword = requireNotNull(keystoreProperties.getProperty("storePassword")) {
                    "key.properties: storePassword is required"
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Flutter embedding references Play split-install / deferred-component APIs. R8 needs
    // these classes on the classpath. Do not use monolithic `play:core:1.10.x` — it
    // duplicates `play:core-common` pulled by other Google Play libraries (e.g. ads).
    implementation("com.google.android.play:feature-delivery:2.1.0")
}