allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Build into project_root/build so Flutter finds the APK at build/app/outputs/flutter-apk/
val projectRootBuildDir = rootProject.layout.projectDirectory.dir("../build")
rootProject.layout.buildDirectory.value(projectRootBuildDir)

subprojects {
    val subprojectBuildDir = rootProject.layout.buildDirectory.dir(project.name)
    project.layout.buildDirectory.value(subprojectBuildDir)
}
// file_saver and older plugins pin AGP 8.1.2; force the app AGP so resolution succeeds.
subprojects {
    buildscript {
        configurations.named("classpath").configure {
            resolutionStrategy.force("com.android.tools.build:gradle:8.9.1")
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
