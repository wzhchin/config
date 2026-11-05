# Makefile Rules

| Rule | Requirement |
| --- | --- |
| Naming | Use `[object-]action[-qualifier...]`; omit the object for a single-object project. |
| Actions | Keep `build`, `run`, `test`, `clean`, and `package` separate. Add only supported operations. |
| Configuration | If an operation distinguishes configurations, name each one, e.g. `server-build-debug` and `server-build-release`; do not add an ambiguous `server-build`. Otherwise omit the configuration. |
| Aggregation | Use `all` for all applicable objects or a group name for a subset. Document the scope and required toolchains. |
| Phony targets | Declare operation and aggregate targets as `.PHONY`, including each prerequisite that is itself an operation. Do not mark actual file targets as `.PHONY`. |
| Help | Do not add a `help` target. |

## Packaging

Use `[object-]package[-platform][-format][-configuration]`. Include each qualifier when needed to distinguish supported operations. Distinguish package formats when a platform has multiple formats. Packaging may depend on the corresponding build target.

| Dimension | Examples |
| --- | --- |
| Object | `server`, `desktop`, `all` |
| Platform | `archlinux`, `debian`, `windows`, `macos`, `android` |
| Format | `zip`, `msi`, `dmg`, `apk`, `aab`, `deb` |
| Configuration | `debug`, `release` |
| Other considerations | Installer or portable form, included dependencies, signing, validation, checksums |

Do not add architecture to target names for now; no architecture variable is prescribed.

## Examples

| Project | Example targets |
| --- | --- |
| Single Rust executable with configurations | `build-debug`, `build-release`, `test` |
| Single Go executable without configurations | `build`, `run`, `test` |
| Rust server, Go worker, and frontend | `server-build-release`, `worker-build`, `frontend-build`, `all-test` |
| Android application | `build-debug`, `build-release`, `package-apk-debug`, `package-aab-release` |
| Go packages `foo`, `bar`, `baz` without build configurations | `foo-build`, `foo-run`, `foo-test`, `foo-clean`, `foo-package`, `bar-build`, `baz-build`, `all-build` |
| Rust packages `foo`, `bar`, `baz` with build configurations | `foo-build-debug`, `foo-build-release`, `foo-run-debug`, `foo-test`, `foo-clean`, `foo-package-release`, `bar-build-release`, `baz-build-release`, `all-build-release` |
| Desktop packages for Windows | `desktop-package-windows-zip`, `desktop-package-windows-msi` |

Examples are not mandatory target sets; include only operations the project supports. Packages may belong to one or multiple projects. Aggregate only objects managed by the Makefile, and document the scope.
