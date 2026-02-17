plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 🔥 BU İKİ SATIR EKLENDİ (Hataları çözen kısım)
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.altinkosenadir.mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.altinkosenadir.mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        ndk {
            abiFilters.add("armeabi-v7a") 
            abiFilters.add("arm64-v8a")   
            abiFilters.add("x86_64")      
        }        
    }

    signingConfigs {
        create("release") {
            // 🔥 HATALI KISIMLAR DÜZELTİLDİ (.getProperty kullanıldı ve 'as String' silindi)
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            
            // Dosya yolunu güvenli alma
            val storeFilePath = keystoreProperties.getProperty("storeFile")
            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
            }
            
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
