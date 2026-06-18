// Suppress specific lint warnings that are safe to ignore
tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions {
        suppressWarnings = false
        allWarningsAsErrors = false
    }
}

// Configure lint options
android {
    lint {
        // Disable warnings about unsupported features
        disable.add("MissingDimensionActivityName")
        disable.add("MissingDimensionBuildType")
        disable.add("MissingTranslation")

        // Enable stricter checks
        enable.add("NewApi")
        enable.add("Deprecated")

        // Fail on critical errors only
        warningLevel = "Warning"
        abortOnError = false
    }
}
