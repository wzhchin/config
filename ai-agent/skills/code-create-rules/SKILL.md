---
name: code-create-rules
description: Default engineering rules for creating a new project or a standalone script or code file outside an existing project. Do not invoke implicitly for work inside an existing project; follow its established conventions unless the user explicitly requests $code-create-rules. When this skill applies, read every matching reference.
---

# Code Creation Rules

Use these defaults only when creating something without an established project context.

## Scope gate

Apply this skill automatically when creating:

- A new project from scratch.
- A standalone script or code file that does not belong to an existing project.

Do not apply it implicitly when the target belongs to an existing project, including when adding a new file there. Inspect and follow that project's repository instructions, structure, naming, tools, and conventions instead.

Apply this skill inside an existing project only when the user explicitly requests `$code-create-rules`. Resolve conflicts through the active instruction hierarchy.

## Load references

1. Confirm that the scope gate allows this skill.
2. Identify every technical domain in the request and affected files.
3. Read `references/core.md` for every task.
4. Read each matching domain reference completely.
5. Read multiple references when the task crosses domains.
6. Resolve conflicts through the active instruction hierarchy.
7. Start creation only after all required reads finish.

## Route domains

| Domain | Triggers | Required reference |
| --- | --- | --- |
| Arch packaging | `PKGBUILD`, `.SRCINFO`, `*.install`, makepkg, or Arch Linux package creation | `references/pkgbuild.md` |
| Project commands | Build, test, run, clean, release, package, deploy, Makefile, or stack command execution | `references/makefile.md` |
| Frontend | HTML, CSS, JavaScript, TypeScript, React, Vite, Tailwind, pnpm, web pages, or browser UI | `references/frontend.md` |
| Python | Python, `.py`, uv, venv, Python dependencies, or Python scripts | `references/python.md` |
| Android build | Android, Gradle wrapper or repositories, `settings.gradle`, `settings.gradle.kts`, `gradle-wrapper.properties`, release signing, or keystore | `references/android-build.md` |
| Shell scripts | Bash, `.sh`, bash shebangs, or extensionless shell scripts | `references/shell-script.md` |

## Extend routing

Place each new domain file directly under `references/`.

Add one routing row for every new domain file.

State concrete triggers and file types in each routing row.

Keep detailed rules in references, not in this file.
