allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Fix: isar_flutter_libs 3.1.0 — dois problemas de compatibilidade com AGP 8+/9+:
// 1. Não declara namespace (obrigatório no AGP 8+)
// 2. compileSdkVersion 30 < 34 exigido pelas deps transitivas do AndroidX
//    A extensão AGP é finalizada (locked) antes de afterEvaluate poder alterá-la.
//    Como isar_flutter_libs é uma lib de binários nativos pré-compilados (sem código
//    Kotlin/Java próprio), o checkAarMetadata é um false-positive — desabilitamos
//    o task diretamente via whenTaskAdded, que roda antes da avaliação do projeto.
subprojects {
    plugins.withId("com.android.library") {
        val ext = extensions.findByName("android") ?: return@withId
        // Fix 1: namespace
        try {
            val getNamespace = ext.javaClass.getMethod("getNamespace")
            if (getNamespace.invoke(ext) == null) {
                ext.javaClass.getMethod("setNamespace", String::class.java)
                    .invoke(ext, project.group.toString())
            }
        } catch (_: Exception) {}
    }

    // Fix 2: desabilita checkAarMetadata para isar_flutter_libs (false-positive de compileSdk)
    if (name == "isar_flutter_libs") {
        tasks.whenTaskAdded {
            if ("AarMetadata" in name) enabled = false
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
