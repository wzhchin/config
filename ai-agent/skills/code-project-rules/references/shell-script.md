# Shell Script Rules

Apply these personal conventions when creating, editing, or reviewing Bash scripts.

## Shebang and strict mode

Start Bash scripts with:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Use `#!/usr/bin/env sh` with `set -eu` only when POSIX compatibility is explicitly required. Never use a hardcoded interpreter path such as `#!/bin/bash`.

## Naming

- Files: lowercase, no extension, and hyphens for compound names, such as `git-cmt-20` or `clean-pkg-deps`.
- Global variables and constants: `UPPER_SNAKE_CASE`, such as `INPUT_FILE`, `WORK_DIR`, and `LOG_DIR`.
- Function locals and parameters: `lower_snake_case`, such as `filepath` and `output_file`. Always declare them with `local`.
- Private and helper functions: use a leading underscore, such as `_edit`, `_help`, and `_msg1`.

## Output and logging

Use `printf` instead of `echo -e`. Define colored logging functions:

```bash
msg()  { printf "\033[32m==> %s %s ~ \033[0m%s\n" "$(date +%H:%M:%S)" "$*" ; }
warn() { printf "\033[33m==> %s %s ~ %s\033[0m\n" "$(date +%H:%M:%S)" "$*" ; }
error(){ printf "\033[31m==> %s %s ~ %s\033[0m\n" "$(date +%H:%M:%S)" "$*" ; }
die()  { error "$@"; exit 1; }
```

Use `==>` for primary, `->` for secondary, and `=>` for tertiary output. Send errors and warnings to standard error with `>&2`.

## Conditionals

Prefer `[[ ]]` over `[ ]`:

```bash
# Preferred
if [[ -z $1 || $1 == help ]]; then

# Avoid
if [ -z "$1" ] || [ "$1" = "help" ]; then
```

Never use the `x` prefix hack for empty checks:

```bash
# Avoid
[ x = "x$VAR" ]

# Preferred
[[ -z $VAR ]]
```

## Argument parsing

Use a manual `while`, `shift`, and `case` pattern:

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

For thin wrapper scripts, pass arguments through with `"$@"`.

## Functions

- Declare functions before use.
- Use `local` for every function-scoped variable.
- Use `export -f` when passing functions to subshells or fzf.
- For dispatch-style scripts, put logic in functions and call the main dispatcher at the bottom.

## Error handling

- Check dependencies with `command -v`, never `which`.
- Use `die()` for fatal errors.
- Use `|| true` only to suppress expected failures.
- Check exit codes explicitly where `set -e` does not apply.

## Quoting and variables

- Quote all variable expansions: `"$var"`, `"${var}"`, and `"${array[@]}"`.
- Prefer `$()` over backticks.
- Use `$(<file)` instead of `cat file` to read file contents.

## Avoid

| Avoid | Use instead |
| --- | --- |
| `cat file \| awk` | `awk ... file` or `awk ... < file` |
| `which cmd` | `command -v cmd` |
| `echo -e` | `printf` |
| `[ x = "x$VAR" ]` | `[[ -z $VAR ]]` |
| Unquoted `$var` | `"$var"` |
| Missing `local` | `local var=...` |
| `set -e` alone | `set -euo pipefail` |

## Formatting

- Indent with four spaces.
- Use backslash continuation for long commands.
- Use `<<-EOF` for indented heredocs.
- Separate logical sections with blank lines.
- Do not add trailing semicolons to regular lines.
