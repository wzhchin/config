# Makefile Rules

## Discover project commands

Look for `Makefile` or `makefile` before project command execution.

If a Makefile exists, run `make help` to discover targets.

If `make help` fails, inspect the Makefile and project documentation for targets.

Use a Make target when it covers the required command.

Do not bypass an available target with npm, Cargo, Gradle, Go, or another stack command.

Pass supported variables with `make <target> VAR=value`.

Unless the user requests a raw command, ask before project commands when no Makefile exists.

If the user agrees, add a minimal Makefile with `help` and applicable project targets.

If the user declines, do not create a Makefile.

## Define public targets

For a new Makefile, or when adding a new public operation, use this naming form:

```text
<action>[-<component>][-<profile>]
```

- Actions include `init`, `test`, `build`, `run`, `package`, `release`, `deploy`, and `clean`.
- Components identify independently operated parts such as `web`, `server`, `android`, or `cli`.
- Profiles identify materially different configurations such as `debug` or `release`.
- Omit the component when the project has only one buildable component.
- Preserve established target names in an existing project unless the user requests a migration.

Examples include `test`, `build-debug`, `build-release`, `build-web-debug`, and `build-server-release`.

Add only targets that represent real project operations. Do not add empty targets or unsupported debug, release, or component combinations merely to complete the naming matrix.

## Target requirements

| Target | Required behavior |
| --- | --- |
| `help` | List public targets, their purpose, and important variables without changing project state. |
| `init` | Perform the repeatable local bootstrap needed before build or test, such as installing dependencies or creating generated local configuration. Make it safe to run more than once. Do not modify user-global configuration without explicit approval. |
| `test` | Run the project's meaningful default automated test suite non-interactively. Return nonzero when tests fail. Add narrower targets such as `test-unit` or `test-integration` only when the project has those suites. |
| `build` | Build the documented default local artifact. Prefer making it an alias of the appropriate concrete build target rather than duplicating its recipe. It must not silently publish or deploy. |
| `build-debug` | Produce a development or diagnostic artifact with the project's debug configuration. Preserve useful diagnostics such as source maps or debug symbols when supported. |
| `build-release` | Produce an optimized production artifact and run required release-build checks. Building a release artifact must not itself publish, deploy, tag, or push it. |
| `build-<component>-debug` | Build only the named component using its debug configuration, for example `build-web-debug` or `build-server-debug`. |
| `build-<component>-release` | Build only the named component using its production configuration, for example `build-web-release` or `build-server-release`. |
| `run` | Start the documented local application or service in the foreground so signals and exit status propagate correctly. Use component or profile suffixes when behavior differs. |
| `package` | Assemble already-built outputs into the project's distributable format without publishing them. |
| `release` | Run the project's established release workflow only when that workflow is explicitly defined. Keep external publication, tagging, and pushing visible; obtain authorization before those mutations. |
| `deploy` | Perform an explicitly requested deployment. Make the destination and environment visible through the target name or documented variables. |
| `clean` | Remove only generated project outputs owned by the corresponding build. Do not remove source files, secrets, user-global caches, or unspecified paths. |

For a multi-component repository, make the aggregate target depend on its component targets when all components are intended:

```make
build-debug: build-web-debug build-server-debug
build-release: build-web-release build-server-release
```

Do not assume `build` means `build-release`. Choose and document the default that matches the project's normal local workflow; prefer `build-debug` when no established default exists.

## Recipe requirements

- Declare command-style targets as `.PHONY`.
- Make public targets thin, stable wrappers around the project's actual tools or scripts.
- Share prerequisites or private helper targets instead of duplicating recipes across debug, release, and component targets.
- Let underlying command failures propagate to Make. Do not hide failures with unconditional success.
- Keep targets non-interactive when practical. Document unavoidable prompts in `make help`.
- Forward supported configuration as Make variables, such as `VERSION`, `PROFILE`, `COMPONENT`, or `OUTPUT_DIR`, and validate unsupported values before starting expensive work.
- Keep debug and release outputs separate when one could overwrite or contaminate the other.
- Do not embed passwords, tokens, private keys, or other secrets in the Makefile or command line. Apply the core secret-handling rule when a target needs them.
- Do not make ordinary build or test targets depend on deployment, publication, or other external mutations.

## Verify Makefile changes

Run `make help` and confirm every added public target is discoverable.

Run the narrowest safe target that exercises the changed recipe. Confirm its exit status and expected output artifact or observable result.

For release, deploy, publish, or destructive targets that are not authorized to run, inspect the expanded recipe with a safe dry run when possible and report that the real operation was not executed.
