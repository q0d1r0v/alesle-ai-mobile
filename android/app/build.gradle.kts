import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("org.jlleitschuh.gradle.ktlint")
}

// Release signing key: android/key.properties (git-ignored; README "Release signing").
// The keystore itself lives outside the repository.
val releaseKey =
    Properties().apply {
        val file = rootProject.file("key.properties")
        if (file.exists()) file.inputStream().use(::load)
    }

android {
    namespace = "com.alesle.ai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // One build, distributed only as an APK from our website
        // (docs/adr/0005 in alesle-ai-api). No product flavors.
        applicationId = "com.alesle.ai"
        // 30 (Android 11): AccessibilityService.takeScreenshot() exists from API 30
        // and needs no MediaProjection consent dialog per capture. The agent's
        // vision fallback depends on it.
        minSdk = 30
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"
        testInstrumentationRunnerArguments["clearPackageData"] = "true"
    }

    signingConfigs {
        if (!releaseKey.isEmpty) {
            create("release") {
                storeFile = file(releaseKey.getProperty("storeFile"))
                storePassword = releaseKey.getProperty("storePassword")
                keyAlias = releaseKey.getProperty("keyAlias")
                keyPassword = releaseKey.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Never the debug key: an APK signed with it could not be updated by the real one.
            signingConfig = signingConfigs.findByName("release")
        }
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            isReturnDefaultValues = false
        }
        execution = "ANDROIDX_TEST_ORCHESTRATOR"
    }

    lint {
        warningsAsErrors = true
        abortOnError = true
        checkDependencies = false
        // Version-freshness checks belong to dependency updates, not to every build.
        disable += setOf("GradleDependency", "NewerVersionAvailable", "AndroidGradlePluginVersion")
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
        allWarningsAsErrors = true
    }
}

ktlint {
    android.set(true)
    // Pigeon output is generated; formatting it by hand would be overwritten.
    filter {
        exclude { it.file.path.contains("/generated/") || it.file.name.endsWith(".g.kt") }
    }
}

dependencies {
    // Same version Flutter's embedding already resolves; declared because the agent code uses it directly.
    implementation("androidx.core:core-ktx:1.13.1")
    // Pigeon's generated Kotlin FlutterApi (AgentEventsApi) uses suspend functions.
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.2")
    testImplementation("junit:junit:4.13.2")
    testImplementation("io.mockk:mockk:1.14.11")
    testImplementation("org.robolectric:robolectric:4.17")
    testImplementation("androidx.test:core-ktx:1.7.0")
    androidTestUtil("androidx.test:orchestrator:1.6.1")
}

flutter {
    source = "../.."
}

// A release build without the key fails here instead of producing an unsigned APK.
gradle.taskGraph.whenReady {
    val buildsRelease = allTasks.any { it.name in setOf("assembleRelease", "bundleRelease", "packageRelease") }
    if (buildsRelease && releaseKey.isEmpty) {
        throw GradleException("Release signing needs android/key.properties (see README, \"Release signing\").")
    }
}

// Robolectric unit tests read merged assets (isIncludeAndroidResources), and
// Flutter's copyFlutterAssets<Variant> writes into that same directory. Gradle 9
// refuses the undeclared overlap, so declare it.
tasks.matching { it.name.startsWith("package") && it.name.endsWith("UnitTestForUnitTest") }.configureEach {
    val variant = name.removePrefix("package").removeSuffix("UnitTestForUnitTest")
    dependsOn("copyFlutterAssets$variant")
}
