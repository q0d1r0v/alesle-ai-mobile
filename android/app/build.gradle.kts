plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("org.jlleitschuh.gradle.ktlint")
}

android {
    namespace = "com.alesle.ai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        buildConfig = true
        resValues = true
    }

    defaultConfig {
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

    // One codebase, two distributions (docs/adr/0003 in alesle-ai-api).
    // The only behavioural difference is ExecutionPolicy, derived from
    // BuildConfig.DISTRIBUTION — never from a second code path.
    flavorDimensions += "distribution"
    productFlavors {
        create("play") {
            dimension = "distribution"
            // Google Play policy (2026-01-28): no autonomous AccessibilityService
            // agents. Every sensitive action waits for the user.
            buildConfigField("String", "DISTRIBUTION", "\"play\"")
            resValue("string", "app_name", "Alesle AI")
        }
        create("direct") {
            dimension = "distribution"
            // APK from the website. Separate id so both can be installed side by side.
            applicationIdSuffix = ".direct"
            buildConfigField("String", "DISTRIBUTION", "\"direct\"")
            resValue("string", "app_name", "Alesle AI Direct")
        }
    }

    buildTypes {
        release {
            // TODO(release): replace with the upload keystore before the first store build.
            signingConfig = signingConfigs.getByName("debug")
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
    testImplementation("junit:junit:4.13.2")
    testImplementation("io.mockk:mockk:1.14.11")
    testImplementation("org.robolectric:robolectric:4.17")
    testImplementation("androidx.test:core-ktx:1.7.0")
    androidTestUtil("androidx.test:orchestrator:1.6.1")
}

flutter {
    source = "../.."
}

// Robolectric unit tests read merged assets (isIncludeAndroidResources), and
// Flutter's copyFlutterAssets<Variant> writes into that same directory. Gradle 9
// refuses the undeclared overlap, so declare it.
tasks.matching { it.name.startsWith("package") && it.name.endsWith("UnitTestForUnitTest") }.configureEach {
    val variant = name.removePrefix("package").removeSuffix("UnitTestForUnitTest")
    dependsOn("copyFlutterAssets$variant")
}
