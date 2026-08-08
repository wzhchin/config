# Makefile Rules

Look for `Makefile` or `makefile` before project command execution.

If a Makefile exists, run `make help` to discover targets.

If `make help` fails, inspect the Makefile and project documentation for targets.

Use a Make target when it covers the required command.

Do not bypass an available target with npm, Cargo, Gradle, Go, or another stack command.

Pass supported variables with `make <target> VAR=value`.

Unless the user requests a raw command, ask before project commands when no Makefile exists.

If the user agrees, add a minimal Makefile with `help` and applicable project targets.

If the user declines, do not create a Makefile.
