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

## Release signing

Use `kpass` from the Makefile to retrieve these Android-specific entries. The Makefile passes the values to Gradle as environment variables; Gradle must not call `kpass` or write signing passwords to a properties file.

| Variable | Default entry | Use |
| --- | --- | --- |
| `PASS_STORE_PASSWORD` | `ANDROID_APP_RELEASE_PASSWORD` | store password |
| `PASS_KEY_PASSWORD` | `ANDROID_APP_RELEASE_PASSWORD` | key password |
| `PASS_KEY_ALIAS` | `ANDROID_APP_RELEASE_ALIAS` | alias text |
| `PASS_KEYSTORE` | `F-android-app-release.keystore` | binary keystore |

Example release section for the project-root `Makefile`:

```makefile
PASS_STORE_PASSWORD ?= ANDROID_APP_RELEASE_PASSWORD
PASS_KEY_PASSWORD ?= ANDROID_APP_RELEASE_PASSWORD
PASS_KEY_ALIAS ?= ANDROID_APP_RELEASE_ALIAS
PASS_KEYSTORE ?= F-android-app-release.keystore
KEYSTORE_FILENAME ?= android-app-release.keystore
export PASS_STORE_PASSWORD PASS_KEY_PASSWORD PASS_KEY_ALIAS PASS_KEYSTORE KEYSTORE_FILENAME

.PHONY: build-release

build-release:
	@set -eu; \
	umask 077; \
	mkdir -p signature; \
	signing_dir=$$(mktemp -d "$$(pwd)/signature/.release.XXXXXXXX"); \
	trap 'rm -rf -- "$$signing_dir"' EXIT; \
	kpass gf "$$PASS_KEYSTORE" "$$signing_dir/$$KEYSTORE_FILENAME" >/dev/null; \
	ANDROID_KEYSTORE_FILE="$$signing_dir/$$KEYSTORE_FILENAME"; \
	test -f "$$ANDROID_KEYSTORE_FILE"; \
	ANDROID_STORE_PASSWORD=$$(kpass get "$$PASS_STORE_PASSWORD"); \
	ANDROID_KEY_PASSWORD=$$(kpass get "$$PASS_KEY_PASSWORD"); \
	ANDROID_KEY_ALIAS=$$(kpass get "$$PASS_KEY_ALIAS"); \
	export ANDROID_KEYSTORE_FILE ANDROID_STORE_PASSWORD ANDROID_KEY_PASSWORD ANDROID_KEY_ALIAS; \
	./gradlew assembleRelease
```

Set `KEYSTORE_FILENAME` to the filename produced by `kpass get-file` when it differs from the default. Keep the temporary keystore under `signature/` and remove it after the build, including when the build fails.

Configure release signing in `app/build.gradle.kts` from `ANDROID_KEYSTORE_FILE`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, and `ANDROID_KEY_ALIAS`. The Makefile supplies an absolute keystore path. Require all four values for a release build and fail with a clear error if any are missing; do not print their values. Debug builds must work without release credentials, and release builds must not fall back to debug signing.

Run the example with `make build-release`. To use different `kpass` entries or a different extracted filename, supply the corresponding variables to Make; for example:

```bash
PASS_KEYSTORE=my-app-release.keystore \
KEYSTORE_FILENAME=my-app-release.keystore \
make build-release
```

The `PASS_*` variables identify `kpass` entries; they do not contain the secret values.

Never hardcode passwords or commit the release keystore. Do not expose secrets in logs or echo commands containing their values.

## Checklist

- Mirrors: set `distributionUrl` to Tencent; put Aliyun repositories first, official repositories last, and retain JitPack. Summarize changes and do not commit unless asked.
- Signing: retrieve credentials and a temporary keystore with `kpass` in the Makefile, pass them to Gradle through environment variables, and keep secrets out of logs and commits.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Wrapper download fails | Use the Huawei URL and confirm the version exists on the mirror. |
| Dependency returns 404 | Put Aliyun first and retain official repositories last. |
| Gradle cache is stale | Delete the affected entry under `~/.gradle/wrapper/dists/`. |
| `kpass` is not found | Check `PATH`; debug builds do not require release credentials. |
| Release signing values are missing | Run the release target through Make and check the `kpass` entry names. |
| Keystore file is missing | Check the `kpass` entry and set `KEYSTORE_FILENAME` to the extracted filename. |
| `XDG_RUNTIME_DIR` is unset | Pass an explicit directory with `get-file ... -o DIR`. |

## Relevant project files

- `settings.gradle.kts`
- `gradle/wrapper/gradle-wrapper.properties`
- `Makefile`
- `app/build.gradle.kts`
- `signature/` (temporary release keystore)
