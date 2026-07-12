import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // Flutter gère Kotlin en interne — kotlin-android n'est plus nécessaire ici
    id("dev.flutter.flutter-gradle-plugin")
}

// Signature de release : lue depuis key.properties (non commité, voir .gitignore
// et key.properties.example). Absent en dev -> fallback sur la clé debug pour
// que `flutter run --release` continue de fonctionner, mais un vrai keystore
// est requis avant toute publication (voir rapport_bugs.md, S11).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.haven_app"
    compileSdk = flutter.compileSdkVersion
	buildToolsVersion = "36.1.0"
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.haven_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Utilise le vrai keystore si key.properties existe, sinon retombe sur
            // la clé debug (dev uniquement — ne jamais publier un build signé debug).
            signingConfig = if (hasReleaseKeystore) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
