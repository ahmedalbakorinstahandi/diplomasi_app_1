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
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
