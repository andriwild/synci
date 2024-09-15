import org.jooq.meta.jaxb.ForcedType
import org.jooq.meta.jaxb.Logging
import org.jooq.meta.jaxb.Property

val javaVersion = 21
val jooqVersion = "3.19.11"
val postgresVersion = "42.7.4"
val postgresJdbcUrl = "jdbc:postgresql://localhost:5432/synci-db"
val postgresUser = "postgres"
val postgresPassword = "postgres"
val hikariCPVersion = "5.1.0"
val kotlinJvmVersion = "1.9.25"

plugins {
	kotlin("jvm") version "2.0.20"
    kotlin("plugin.serialization") version "2.0.20"
	kotlin("plugin.spring") version "2.0.20"
	id("org.springframework.boot") version "3.3.3"
	id("io.spring.dependency-management") version "1.1.6"
    id("org.flywaydb.flyway") version "9.7.0"
    id("nu.studer.jooq") version "9.0"
}

configurations {
    create("flywayMigration")
}

group = "ch.boosters"
version = "0.0.1-SNAPSHOT"

java {
	toolchain {
		languageVersion = JavaLanguageVersion.of(javaVersion)
	}
}

repositories {
	mavenCentral()
}

dependencies {
    implementation("com.zaxxer:HikariCP:$hikariCPVersion")
    implementation("org.springframework.boot:spring-boot-starter-jdbc")
	implementation("org.springframework.boot:spring-boot-starter-webflux")
	implementation("org.springframework.boot:spring-boot-starter-quartz")
	implementation("org.mnode.ical4j:ical4j:4.0.4")
	implementation("com.google.code.gson:gson")
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("org.springframework.boot:spring-boot-devtools")
    implementation("org.springframework.boot:spring-boot-starter-quartz")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
	implementation("io.projectreactor.kotlin:reactor-kotlin-extensions")
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json")
    implementation("org.jetbrains.kotlinx:kotlinx-datetime:0.6.1")
    implementation("org.postgresql:postgresql:$postgresVersion")
	implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-oauth2-resource-server")
    "flywayMigration"("org.postgresql:postgresql:$postgresVersion")
    jooqGenerator("org.postgresql:postgresql:$postgresVersion")
	developmentOnly("org.springframework.boot:spring-boot-devtools")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
	testImplementation("io.projectreactor:reactor-test")
	testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
	testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

flyway {
    configurations = arrayOf("flywayMigration")
    url = postgresJdbcUrl
    user = postgresUser
    password = postgresPassword
}

jooq {
    version.set(jooqVersion)
    edition.set(nu.studer.gradle.jooq.JooqEdition.OSS)  // default (can be omitted)

    configurations {
        create("main") {  // name of the jOOQ configuration
            generateSchemaSourceOnCompilation.set(true)  // default (can be omitted)

            jooqConfiguration.apply {
                logging = Logging.WARN
                jdbc.apply {
                    driver = "org.postgresql.Driver"
                    url = postgresJdbcUrl
                    user = "postgres"
                    password = "postgres"
                }
                generator.apply {
                    name = "org.jooq.codegen.DefaultGenerator"
                    database.apply {
                        name = "org.jooq.meta.postgres.PostgresDatabase"
                        inputSchema = "public"
                    }
                    generate.apply {
                        isDeprecated = false
                        isRecords = true
                        isImmutablePojos = true
                        isFluentSetters = true
                    }
                    target.apply {
                        packageName = "ch.boosters.data"
                        directory = "build/generated-src/jooq/main"  // default (can be omitted)
                    }
                    strategy.name = "org.jooq.codegen.DefaultGeneratorStrategy"
                }
            }
        }
    }
}

kotlin {
	compilerOptions {
		freeCompilerArgs.addAll("-Xjsr305=strict")
	}
}

tasks.named<nu.studer.gradle.jooq.JooqGenerate>("generateJooq") {
    // generateJooq can be configured to use a different/specific toolchain
    // dependsOn(tasks.named("flywayMigrate"))
    // inputs.files(fileTree("src/main/resources/db/migration"))
    //     .withPropertyName("migrations")
    //     .withPathSensitivity(PathSensitivity.RELATIVE)
    (launcher::set)(javaToolchains.launcherFor {
        languageVersion.set(JavaLanguageVersion.of(javaVersion))
    })
    allInputsDeclared.set(true)
}

tasks.withType<Test> {
	useJUnitPlatform()
}
