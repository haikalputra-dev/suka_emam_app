// TAMBAHKAN IMPORT INI DI PALING ATAS
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

// DIUBAH: Kode untuk membaca properties dengan sintaks Kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.suka_emam_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.3.13750724" // Pastikan versi ndk ini benar, atau hapus baris ini agar Flutter menggunakan versi defaultnya

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.sukaemam.pandora"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // DIUBAH: Blok signingConfigs dengan sintaks Kotlin
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    // DIUBAH: Blok buildTypes dengan sintaks Kotlin
    buildTypes {
        getByName("release") {
            // Menentukan konfigurasi signing untuk build rilis
            signingConfig = signingConfigs.getByName("release")
            
            // Properti lainnya (pastikan menggunakan tanda =)
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}