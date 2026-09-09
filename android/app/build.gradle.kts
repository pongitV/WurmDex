plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.wurmdex.wurmdex"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.wurmdex.wurmdex"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}

// Automatically copy generated APKs to the project's root dist/android/ folder
android.applicationVariants.all {
    val variant = this
    val variantName = variant.name.replaceFirstChar { it.uppercase() }
    val distDir = rootProject.projectDir.resolve("../../dist/android")

    val copyApkTask = tasks.register<Copy>("copy${variantName}ApkToDist") {
        description = "Copies generated APK to dist/android/"
        from(layout.buildDirectory.dir("outputs/flutter-apk"))
        include("app-$name.apk", "app.apk")
        into(distDir)
        rename { fileName ->
            if (fileName.contains("release")) "WurmDex-release.apk" else "WurmDex-$name.apk"
        }
    }

    variant.assembleProvider.configure {
        finalizedBy(copyApkTask)
    }
}

