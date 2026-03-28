---
name: shell-script-style
description: Enforce personal shell scripting conventions when writing or editing bash scripts. Use when creating, modifying, or reviewing shell scripts (.sh, bash scripts in PATH, or any file with bash shebang).
---

# Shell Script Style

Personal bash scripting conventions and best practices.

## Shebang and set

Always start bash scripts with:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Use `#!/usr/bin/env sh` with `set -eu` only when POSIX compatibility is explicitly required. Never use hardcoded paths like `#!/bin/bash`.

## Naming

- **Files**: lowercase, no extension, hyphens for compound names (e.g. `git-cmt-20`, `clean-pkg-deps`).
- **Global variables and constants**: UPPER_SNAKE_CASE (e.g. `INPUT_FILE`, `WORK_DIR`, `LOG_DIR`).
- **Function locals and parameters**: lower_snake_case (e.g. `filepath`, `output_file`). Always declare with `local`.
- **Private/helper functions**: leading underscore prefix (e.g. `_edit`, `_help`, `_msg1`).

## Output and logging

Use `printf` instead of `echo -e`. Define colored logging functions:

```bash
msg()  { printf "\033[32m==> %s %s ~ \033[0m%s\n" "$(date +%H:%M:%S)" "$*" ; }
warn() { printf "\033[33m==> %s %s ~ %s\033[0m\n" "$(date +%H:%M:%S)" "$*" ; }
error(){ printf "\033[31m==> %s %s ~ %s\033[0m\n" "$(date +%H:%M:%S)" "$*" ; }
die()  { error "$@"; exit 1; }
```

Arrow hierarchy: `==>` primary, `->` secondary, `=>` tertiary. Use `>&2` for error/warning output.

## Conditionals

Prefer `[[ ]]` over `[ ]`:

```bash
# Good
if [[ -z $1 || $1 == help ]]; then

# Avoid
if [ -z "$1" ] || [ "$1" = "help" ]; then
```

Never use `x` prefix hack for empty checks:

```bash
# Bad
[ x = "x$VAR" ]

# Good
[[ -z $VAR ]]
```

## Argument parsing

Use manual `while + shift + case` pattern:

```bash
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i) INPUT_FILE="$2"; shift ;;
        -v) VERBOSE=true ;;
        -h|--help) show_help; exit 0 ;;
        *) ARGS+=("$1") ;;
    esac
    shift
done
```

For thin wrapper scripts, pass through with `"$@"`.

## Functions

- Declare before use, always.
- Use `local` for all function-scoped variables.
- Use `export -f` when passing functions to subshells or fzf.
- For dispatch-style scripts, put all logic in functions and call a main dispatch at the bottom.

## Error handling

- Check dependencies with `command -v`, never `which`.
- Use `die()` for fatal errors.
- Use `|| true` to suppress expected failures.
- Check exit codes explicitly when `set -e` doesn't cover the case.

## Quoting and variables

- Quote all variable expansions: `"$var"`, `"${var}"`, `"${array[@]}"`.
- Prefer `$()` over backticks.
- Use `$(<file)` instead of `cat file` for reading file contents.

## Avoid

| Avoid | Use instead |
|-------|-------------|
| `cat file \| awk` | `awk ... file` or `awk ... < file` |
| `which cmd` | `command -v cmd` |
| `echo -e` | `printf` |
| `[ x = "x$VAR" ]` | `[[ -z $VAR ]]` |
| Unquoted `$var` | `"$var"` |
| Missing `local` | `local var=...` |
| `set -e` alone | `set -euo pipefail` |

## Formatting

- 4 spaces for indentation.
- Backslash `\` for line continuation on long commands.
- Heredoc with `<<-EOF` to allow indentation.
- Blank lines to separate logical sections.
- No trailing semicolons on regular lines.
