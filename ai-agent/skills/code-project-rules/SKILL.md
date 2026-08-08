---
name: code-project-rules
description: Mandatory engineering rules for code projects. Use before creating, editing, reviewing, debugging, testing, building, or configuring project code. Apply to source files, scripts, dependencies, build tools, and project configuration. Read every reference that matches the task.
---

# Code Project Rules

Load the applicable engineering rules before project work.

## Load references

1. Identify every technical domain in the request and affected files.
2. Read `references/core.md` for every task.
3. Read each matching domain reference completely.
4. Read multiple references when the task crosses domains.
5. Resolve conflicts through the active instruction hierarchy.
6. Start project work only after all required reads finish.

## Route domains

| Domain | Triggers | Required reference |
| --- | --- | --- |
| Arch packaging | `PKGBUILD`, `.SRCINFO`, `*.install`, makepkg, or Arch Linux package creation | `references/pkgbuild.md` |
| Project commands | Build, test, run, clean, release, package, deploy, Makefile, or stack command execution | `references/makefile.md` |
| Frontend | HTML, CSS, JavaScript, TypeScript, React, Vite, Tailwind, pnpm, web pages, or browser UI | `references/frontend.md` |
| Python | Python, `.py`, uv, venv, Python dependencies, or Python scripts | `references/python.md` |

## Extend routing

Place each new domain file directly under `references/`.

Add one routing row for every new domain file.

State concrete triggers and file types in each routing row.

Keep detailed rules in references, not in this file.
