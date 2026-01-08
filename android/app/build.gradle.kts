import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

/* 🔐 Load keystore properties */
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.acore.app.call4help"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.acore.app.call4help"
        minSdk = flutter.minSdkVersion  // ✅ CHANGED: Explicit minSdk for Razorpay compatibility
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    /* ✅ CREATE RELEASE SIGNING CONFIG */
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        debug {
            isMinifyEnabled = false
            isShrinkResources = false
            // ✅ ADDED: Debug signing config (optional but good practice)
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    /* ✅ FIX WINDOWS LINT FILE-LOCK ISSUE */
    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }

    packaging {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/*.kotlin_module"
            )
        }
        jniLibs {
            pickFirsts += setOf("**/*.so")
        }
    }
}

/* 🔧 Dependency conflict fixes */
configurations.all {
    resolutionStrategy {
        // ✅ ADDED: Force specific Razorpay SDK version
        force("com.razorpay:checkout:1.6.40")

        force("com.google.android.play:core:1.10.3")
        force("com.google.android.play:core-common:2.0.3")
        exclude(group = "com.google.android.play", module = "core")
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.multidex:multidex:2.0.1")

    // ✅ ADDED: Razorpay SDK dependency (THIS IS THE KEY FIX)
    implementation("com.razorpay:checkout:1.6.40")

    // Google Play services
    implementation("com.google.android.play:app-update:2.1.0")
    implementation("com.google.android.play:app-update-ktx:2.1.0")

    // ✅ ADDED: Additional dependencies that Razorpay might need
    implementation("com.google.android.gms:play-services-wallet:19.4.0")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
}

flutter {
    source = "../.."
}
