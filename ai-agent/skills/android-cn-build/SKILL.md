---
name: android-cn-build
description: >
  将 Android/Gradle 项目的仓库与发行包下载切到大陆镜像，并用 Makefile + pass-sliver
  完成签名与打包。适用于：国内加速 Gradle、阿里云/腾讯云镜像、settings.gradle 仓库、
  distributionUrl、make release/debug/signing、keystore、pass-sliver、ReadYou 构建。
  触发词：大陆镜像、国内源、gradle 镜像、阿里云 maven、腾讯云 gradle、make release、
  签名打包、/android-cn-build。
---

# Android 大陆镜像 + Makefile 构建

在国内网络下配置 Gradle/Maven 镜像，并按项目 Makefile 完成签名与 APK 构建。

## 何时使用

- 用户要求改「代理源 / 国内源 / 大陆镜像 / 阿里云 / 腾讯云」
- 用户要求 `make release`、`make debug`、签名、安装 release
- 在 ReadYou 或同类 Android 项目里构建/发包

## 1. 大陆镜像（必做模板）

### 1.1 Gradle Wrapper 发行包

改 `gradle/wrapper/gradle-wrapper.properties` 的 `distributionUrl`，**保留原版本号**：

```properties
# 官方（慢）
# distributionUrl=https\://services.gradle.org/distributions/gradle-X.Y-bin.zip

# 腾讯云（推荐）
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-X.Y-bin.zip
```

备选：

- 华为云：`https://mirrors.huaweicloud.com/gradle/gradle-X.Y-bin.zip`

注意：properties 里 URL 中的 `:` 需转义为 `\:`。

### 1.2 依赖与插件仓库

改 `settings.gradle.kts`（或 Groovy 版 `settings.gradle`）。**镜像优先，官方源兜底**；保留 JitPack（无稳定公共大陆镜像）。

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

镜像对照：

| 用途 | 阿里云 URL |
|------|------------|
| Google / AndroidX | `https://maven.aliyun.com/repository/google` |
| Gradle Plugin Portal | `https://maven.aliyun.com/repository/gradle-plugin` |
| Maven Central 等 | `https://maven.aliyun.com/repository/public` |

### 1.3 操作步骤

1. 读现有 `gradle-wrapper.properties` 与 `settings.gradle(.kts)`，记下 Gradle 版本与是否已有自定义仓库。
2. 只改仓库/下载地址，不改插件版本、不删项目特有仓库（如 JitPack）。
3. 若项目用 `dependencyResolutionManagement` + `FAIL_ON_PROJECT_REPOS`，只改 settings，不要在子模块 `build.gradle` 再加 `repositories`。
4. 改完可跑 `./gradlew tasks` 或 `make list-tasks` 做冒烟；首次会拉发行包与依赖。

### 1.4 不要做

- 不要把密钥、密码写进 skill 或提交到 git。
- 不要无故升级 Gradle / AGP 版本（只换 URL 主机）。
- 不要删掉官方源兜底（镜像缺包时回退）。

## 2. Makefile 构建（ReadYou 模式）

项目根目录 `Makefile` 约定如下。构建优先走 Make，而不是手写冗长 `./gradlew assemble...`。

### 2.1 常用目标

| 命令 | 作用 |
|------|------|
| `make help` | 打印目标与变量说明 |
| `make signing` | 从 pass-sliver 导出 keystore + 写 `keystore_release.properties` |
| `make release` | `signing` + 打当前 flavor 的 release |
| `make debug` | 打 debug（可用已提交的 `keystore.properties`） |
| `make assemble` | 按 `FLAVOR` / `BUILD_TYPE` 组装 |
| `make install-release` | 签名后安装到设备 |
| `make list-tasks` | 列出 assemble/install 相关 Gradle 任务 |
| `make clean` | Gradle clean + 删除生成的 release props / 临时目录 |

### 2.2 变量

```bash
FLAVOR=github|fdroid|googlePlay   # 默认 github
BUILD_TYPE=release|debug          # 默认 release
```

示例：

```bash
make release
make release FLAVOR=fdroid
make debug FLAVOR=googlePlay
make assemble FLAVOR=github BUILD_TYPE=debug
make install-release
```

Gradle 任务名由 flavor/buildType 首字母大写拼接，例如：

- `github` + `release` → `assembleGithubRelease`
- `googlePlay` + `debug` → `assembleGooglePlayDebug`

### 2.3 签名与密钥（pass-sliver）

**依赖**：`pass-sliver` 在 PATH 中。

默认条目名（可用 `PASS_*=...` 覆盖）：

| 变量 | 默认 entry | 用途 |
|------|------------|------|
| `PASS_STORE_PASSWORD` | `ANDROID_APP_RELEASE_PASSWORD` | store 密码 |
| `PASS_KEY_PASSWORD` | `ANDROID_APP_RELEASE_PASSWORD` | key 密码 |
| `PASS_KEY_ALIAS` | `ANDROID_APP_RELEASE_ALIAS` | alias 文本 |
| `PASS_KEYSTORE` | `android-app-release.keystore` | 二进制 keystore（`pass-sliver put-file`） |

生成文件（**勿提交** release 产物）：

- `signature/reader.keystore` — 从 pass 导出
- `signature/keystore_release.properties` — `make signing-props` 写入

`app/build.gradle.kts` 加载顺序：

1. 若存在 `signature/keystore_release.properties` → 用于 release 签名（`make signing` 产出）
2. 否则回退 `signature/keystore.properties`（本地 debug 用，可能已提交）

properties 字段：`storePassword`、`keyPassword`、`keyAlias`、`storeFile`。

### 2.4 推荐工作流

**Debug 快速构建**（不强制 pass）：

```bash
make debug
# 或
make assemble FLAVOR=github BUILD_TYPE=debug
```

**正式 release**：

```bash
make release                    # 默认 github release
make install-release            # 装到已连接设备
```

**仅刷新签名材料**：

```bash
make signing
```

**清理**：

```bash
make clean   # 会删 keystore_release.properties 与 PASS_TMPDIR
```

### 2.5 产物

- APK 名形如：`ReadYou-{versionName}-{gitShortHash}.apk`
- Flavor：`github`（默认）、`fdroid`、`googlePlay`（`applicationIdSuffix = .google.play`）

## 3. Agent 执行清单

当用户说「改成大陆源」时：

1. 改 `gradle-wrapper.properties` 的 `distributionUrl` → 腾讯云（保留版本）。
2. 改 `settings.gradle.kts` 仓库 → 阿里云优先 + 官方兜底 + 保留 JitPack。
3. 简短说明改了哪些文件；不主动 commit。

当用户说「打包 / release / 安装」时：

1. 先 `make help` 或读 Makefile，确认 target/变量。
2. 需要签名时用 `make signing` / `make release`（依赖 pass-sliver）。
3. 不要手写密码；不要把 `keystore_release.properties` 或 keystore 二进制提交进 git。
4. 国内环境若依赖仍慢，先确认第 1 节镜像已生效。

## 4. 故障排查

| 现象 | 处理 |
|------|------|
| `pass-sliver not found` | 安装/加入 PATH；或改用已有 `signature/keystore.properties` 做 debug |
| 签名 props 缺失导致 release 失败 | 先 `make signing` |
| Gradle 发行包下载失败 | 换华为云 URL，或检查版本号是否在镜像中存在 |
| 依赖 404 | 确认阿里云 `public`/`google` 在前，官方源仍在列表末尾 |
| 已缓存旧 Gradle | 删除 `~/.gradle/wrapper/dists/` 中对应版本后重试 |

## 5. 参考文件（ReadYou）

- `Makefile` — 签名与 assemble 入口
- `settings.gradle.kts` — 仓库
- `gradle/wrapper/gradle-wrapper.properties` — 发行包 URL
- `app/build.gradle.kts` — flavor、signingConfigs、APK 命名
- `signature/keystore.properties` — debug 回退签名配置
- `signature/keystore_release.properties` — release（生成，勿提交）
