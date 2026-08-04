---
name: project-make
description: >
  Prefer the project Makefile as the single interface for build/test/run/release
  across stacks (frontend, backend, Cargo, Android, etc.). Prefer make over raw
  npm/cargo/gradle/go. Use for: make help, Makefile workflow, unified make interface.
---

# Project Make

If a `Makefile` exists, use it—do not bypass with raw stack CLIs (`npm`, `cargo`, `./gradlew`, `go`, …).

```bash
make help    # discover targets first
make <target> [VAR=value]
```

## No Makefile

If the project has no Makefile, **ask the user** whether to create one that wraps the stack tools (build / test / run / clean / release as applicable). Do not create it unprompted after they decline; if they agree, add a minimal Makefile with `help` and the real commands behind targets.

## Agent checklist

1. Look for `Makefile` / `makefile`.
2. Missing → ask to create; present exists → `make help` then use targets.
3. Prefer `make …` over stack-native commands when a target covers the job.
