# Android Build Rules

Use these rules for Android and Gradle work involving mainland China mirrors or release signing.

## Gradle wrapper distribution

Edit `gradle/wrapper/gradle-wrapper.properties`. Keep the existing Gradle version and escape `:` as `\:`.

```properties
# Tencent (preferred)
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-X.Y-bin.zip
# Huawei fallback
# distributionUrl=https\://mirrors.huaweicloud.com/gradle/gradle-X.Y-bin.zip
```

## Dependency and plugin repositories

Edit `settings.gradle.kts` or `settings.gradle`. Put mirrors first and official repositories last. Keep JitPack.

```kotlin
pluginManagement {
    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://jitpack.io") }
        google()
        mavenCentral()
    }
}
```

| Use | Aliyun URL |
| --- | --- |
| Google / AndroidX | `https://maven.aliyun.com/repository/google` |
| Gradle Plugin Portal | `https://maven.aliyun.com/repository/gradle-plugin` |
| Maven Central and other public artifacts | `https://maven.aliyun.com/repository/public` |

## Release signing with kpass

Require `kpass` on `PATH`.

```bash
kpass get ENTRY
kpass get-file ENTRY [-o OUTPUT_DIR]   # default: $XDG_RUNTIME_DIR
kpass put ENTRY
kpass put-file PATH ENTRY
```

| Variable | Default entry | Use |
| --- | --- | --- |
| `PASS_STORE_PASSWORD` | `ANDROID_APP_RELEASE_PASSWORD` | store password |
| `PASS_KEY_PASSWORD` | `ANDROID_APP_RELEASE_PASSWORD` | key password |
| `PASS_KEY_ALIAS` | `ANDROID_APP_RELEASE_ALIAS` | alias text |
| `PASS_KEYSTORE` | `android-app-release.keystore` | binary keystore |

```bash
kpass get "${PASS_STORE_PASSWORD:-ANDROID_APP_RELEASE_PASSWORD}"
kpass get "${PASS_KEY_ALIAS:-ANDROID_APP_RELEASE_ALIAS}"
kpass get-file "${PASS_KEYSTORE:-android-app-release.keystore}" -o signature
```

Write generated release material only under `signature/`: the keystore and `keystore_release.properties`.

```properties
storePassword=...
keyPassword=...
keyAlias=...
storeFile=reader.keystore
```

In `app/build.gradle.kts`, load `keystore_release.properties` when present; otherwise use `keystore.properties` as the debug fallback.

Never hardcode passwords. Never commit the release keystore or signing properties. Do not expose secrets in logs.

## Checklist

- Mirrors: set `distributionUrl` to Tencent; put Aliyun repositories first, official repositories last, and retain JitPack. Summarize changes and do not commit unless asked.
- Signing: confirm `kpass` is on `PATH`; export secrets and the keystore; write only `signature/keystore_release.properties`; keep secrets out of logs and commits.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Wrapper download fails | Use the Huawei URL and confirm the version exists on the mirror. |
| Dependency returns 404 | Put Aliyun first and retain official repositories last. |
| Gradle cache is stale | Delete the affected entry under `~/.gradle/wrapper/dists/`. |
| `kpass` is not found | Check `PATH`, or use debug `signature/keystore.properties`. |
| Signing properties are missing | Export them with `kpass`. |
| `XDG_RUNTIME_DIR` is unset | Pass an explicit directory with `get-file ... -o DIR`. |

## Relevant project files

- `settings.gradle.kts`
- `gradle/wrapper/gradle-wrapper.properties`
- `app/build.gradle.kts`
- `signature/keystore.properties` (debug)
- `signature/keystore_release.properties` (generated)
