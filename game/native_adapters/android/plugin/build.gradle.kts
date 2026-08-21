plugins {
    id("com.android.library")
    kotlin("android")
}

android {
    namespace = "space.manus.nightfall.bridge"
    compileSdk = 35

    defaultConfig {
        minSdk = 24
        consumerProguardFiles("consumer-rules.pro")
    }

    buildFeatures { buildConfig = false }
    kotlinOptions { jvmTarget = "17" }
}

base { archivesName.set("NightfallAndroidPreferenceBridge") }

dependencies {
    implementation("org.godotengine:godot:4.7.2.stable")
}

tasks.register<Copy>("assembleGodotAddon") {
    group = "distribution"
    description = "Packages debug and release AARs with Godot v2 export scripts."
    dependsOn("assembleDebug", "assembleRelease")
    into(rootProject.layout.buildDirectory.dir("godot_addon/NightfallAndroidPreferenceBridge"))
    from("src/main/godot_addon")
    from(layout.buildDirectory.file("outputs/aar/NightfallAndroidPreferenceBridge-debug.aar")) { into("bin") }
    from(layout.buildDirectory.file("outputs/aar/NightfallAndroidPreferenceBridge-release.aar")) { into("bin") }
}
