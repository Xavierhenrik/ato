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

    // Fix 2: desabilita writeAarMetadata e checkAarMetadata para isar_flutter_libs.
    // isar_flutter_libs 3.1.0 é pré-compilado com compileSdk=30; o checkAarMetadata do AGP
    // 9+ falha com false-positive de "compileSdkVersion too low". O writeAarMetadata é
    // desabilitado junto para que a task bundleXxxAar não sobrescreva os arquivos de
    // metadados que pre-criamos manualmente em build/isar_flutter_libs/intermediates/
    // (debug, release e profile). Veja: android/build.gradle.kts — seção Fix 2.
    if (name == "isar_flutter_libs") {
        tasks.whenTaskAdded {
            if ("AarMetadata" in name) enabled = false
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
