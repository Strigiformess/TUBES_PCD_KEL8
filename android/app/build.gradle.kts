plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.freshcheck"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    androidResources {
        noCompress += "tflite"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // PERBAIKAN: Ganti kotlin { jvmToolchain(17) } dengan kotlinOptions
    // agar Java dan Kotlin target sama persis (tidak konflik dengan tflite_flutter)
    kotlin {
        jvmToolchain(17)
    }

    defaultConfig {
        applicationId = "com.example.freshcheck"
        minSdk = maxOf(26, flutter.minSdkVersion ?: 26)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}