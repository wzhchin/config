---
name: android-build
description: >
  China mirrors for Android/Gradle and release signing via pass-sliver.
  Use for: mainland Gradle/Maven mirrors, Aliyun/Tencent, settings.gradle,
  distributionUrl, pass-sliver, keystore, ANDROID_APP_RELEASE_*, signing props.
---

# Gradle wrapper distribution

Edit `gradle/wrapper/gradle-wrapper.properties`. Keep version; escape `:` as `\:`.

```properties
# Tencent (preferred)
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-X.Y-bin.zip
# Huawei fallback
# distributionUrl=https\://mirrors.huaweicloud.com/gradle/gradle-X.Y-bin.zip
```

# Dependency and plugin repos

Edit `settings.gradle.kts` (or `settings.gradle`). Mirrors first, official last. Keep JitPack.

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
|-----|------------|
| Google / AndroidX | `https://maven.aliyun.com/repository/google` |
| Gradle Plugin Portal | `https://maven.aliyun.com/repository/gradle-plugin` |
| Maven Central etc. | `https://maven.aliyun.com/repository/public` |

# Signing (pass-sliver)

Requires `pass-sliver` on `PATH`. Store: `$CHIN_PRIVATE_DIR/certs/sliver-store`.

```bash
pass-sliver get ENTRY
pass-sliver get-file ENTRY [-o OUTPUT_DIR]   # default: $XDG_RUNTIME_DIR
pass-sliver put ENTRY
pass-sliver put-file PATH ENTRY
```

| Variable | Default entry | Use |
|----------|---------------|-----|
| `PASS_STORE_PASSWORD` | `ANDROID_APP_RELEASE_PASSWORD` | store password |
| `PASS_KEY_PASSWORD` | `ANDROID_APP_RELEASE_PASSWORD` | key password |
| `PASS_KEY_ALIAS` | `ANDROID_APP_RELEASE_ALIAS` | alias text |
| `PASS_KEYSTORE` | `android-app-release.keystore` | binary keystore |

```bash
pass-sliver get "${PASS_STORE_PASSWORD:-ANDROID_APP_RELEASE_PASSWORD}"
pass-sliver get "${PASS_KEY_ALIAS:-ANDROID_APP_RELEASE_ALIAS}"
pass-sliver get-file "${PASS_KEYSTORE:-android-app-release.keystore}" -o signature
```

Generated (do not commit): `signature/` keystore + `keystore_release.properties`

```properties
storePassword=...
keyPassword=...
keyAlias=...
storeFile=reader.keystore
```

Load order in `app/build.gradle.kts`: `keystore_release.properties` if present, else `keystore.properties` (debug fallback).

Never hardcode passwords; never commit release keystore/props.

## Agent checklist

**Mirrors:** `distributionUrl` → Tencent; settings → Aliyun first + official last + JitPack; summarize; no commit unless asked.

**Signing:** `pass-sliver` on PATH → export secrets/keystore → write `signature/keystore_release.properties` only; no secrets in logs/commits.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Wrapper download fails | Huawei URL; check version on mirror |
| Dependency 404 | Aliyun first; official last |
| Stale Gradle cache | Delete under `~/.gradle/wrapper/dists/` |
| `pass-sliver not found` | PATH / debug `signature/keystore.properties` |
| Missing signing props | Export via pass-sliver |
| `XDG_RUNTIME_DIR` unset | `get-file … -o DIR` |

## Reference files

- `settings.gradle.kts`, `gradle/wrapper/gradle-wrapper.properties`
- `app/build.gradle.kts`
- `signature/keystore.properties` (debug), `signature/keystore_release.properties` (generated)
